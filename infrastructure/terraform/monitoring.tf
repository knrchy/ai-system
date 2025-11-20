#################################################
# Helm Release: Prometheus + Grafana + Alertmanager
# This resource uses Helm to deploy the kube-prometheus-stack.
# It is configured to install into the existing 'monitoring' namespace,
# which is looked up using a data source.
#################################################
resource "helm_release" "prometheus" {
  count      = var.monitoring_enabled ? 1 : 0
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = data.kubernetes_namespace.monitoring.metadata[0].name
  version    = "51.0.0" # Using a specific, recent version for stability

  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          retention = "30d"
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                accessModes = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "50Gi"
                  }
                }
              }
            }
          }
          resources = {
            requests = {
              memory = "2Gi"
              cpu    = "1000m"
            }
            limits = {
              memory = "2Gi"
              cpu    = "1000m"
            }
          }
        }
      }
      grafana = {
        enabled       = true
        adminPassword = "admin" # Change this in production!
        service = {
          type     = "NodePort"
          nodePort = 30300
        }
        persistence = {
          enabled = true
          size    = "10Gi"
        }
      }
      alertmanager = {
        enabled = true
      }
    })
  ]
}


#################################################
# Wait for Prometheus CRDs to be available
# This resource solves the "no matches for kind" race condition.
# It runs after the Helm release starts and actively polls the Kubernetes API
# until the ServiceMonitor CRD is in an 'Established' state.
#################################################
resource "null_resource" "wait_for_prometheus_crds" {
  count = var.monitoring_enabled ? 1 : 0

  # This trigger ensures the wait only happens after the Helm release begins installation.
  triggers = {
    release_name = helm_release.prometheus[0].name
  }

  # This provisioner will retry until the command succeeds or times out.
  provisioner "local-exec" {
    # This command will fail until the ServiceMonitor CRD is registered.
    # The timeout is set to 5 minutes (300s).
    command = "kubectl wait --for=condition=established --timeout=300s crd/servicemonitors.monitoring.coreos.com"
  }

  depends_on = [helm_release.prometheus]
}

#################################################
# Introduce a short delay after CRD establishment
# This prevents the kubernetes_manifest provider from
# validating too quickly after the kubectl wait succeeds.
#################################################
resource "time_sleep" "post_crd_wait_delay" {
  count = var.monitoring_enabled ? 1 : 0
  
  # Wait for 5 seconds (this is often enough to solve the race)
  create_duration = "5s" 

  # Ensures this sleep only starts *after* the kubectl wait is done.
  depends_on = [null_resource.wait_for_prometheus_crds]
}

#################################################
# ServiceMonitor for custom trading metrics
# This manifest defines how Prometheus should scrape metrics from our
# custom trading application. It will only be applied after the
# wait_for_prometheus_crds resource has successfully completed.
#################################################
resource "kubernetes_manifest" "trading_service_monitor" {
  count = var.monitoring_enabled ? 1 : 0

  # Crucial for ignoring the GVK validation error during plan/early apply
  validation = "false" 

  # Gives the API server more time to respond during the actual apply phase
  override_send_timeout = "10s"

  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "trading-metrics"
      # This correctly refers to the 'trading-system' namespace data source
      namespace = data.kubernetes_namespace.trading_system.metadata[0].name
      labels = {
        # This label is crucial. It tells the Prometheus Operator to notice this ServiceMonitor.
        release = "prometheus"
      }
    }
    spec = {
      # This selector tells the ServiceMonitor which Service to look for.
      selector = {
        matchLabels = {
          app = "trading-api"
        }
      }
      # This section defines the endpoint on the Service to scrape.
      endpoints = [
        {
          port     = "metrics"
          interval = "30s"
          path     = "/metrics"
        }
      ]
    }
  }

  # Explicit dependency on the wait resource ensures the CRD exists before this is created.
  #depends_on = [
  #  null_resource.wait_for_prometheus_crds,
  #  data.kubernetes_namespace.trading_system
  #]
  depends_on = [
    time_sleep.post_crd_wait_delay,
    data.kubernetes_namespace.trading_system
  ]
}
