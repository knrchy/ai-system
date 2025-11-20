#################################################
# Helm Release: Prometheus + Grafana + Alertmanager
# This resource uses Helm to deploy the kube-prometheus-stack.
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
# This ensures the ServiceMonitor CRD is 'Established'.
#################################################
resource "null_resource" "wait_for_prometheus_crds" {
  count = var.monitoring_enabled ? 1 : 0

  # This trigger ensures the wait only happens after the Helm release begins installation.
  triggers = {
    release_name = helm_release.prometheus[0].name
  }

  # This command will fail until the ServiceMonitor CRD is registered.
  provisioner "local-exec" {
    command = "kubectl wait --for=condition=established --timeout=300s crd/servicemonitors.monitoring.coreos.com"
  }

  depends_on = [helm_release.prometheus]
}

#################################################
# Introduce a short delay after CRD establishment
# This is a robust measure against the Kubernetes provider's fast validation.
#################################################
resource "time_sleep" "post_crd_wait_delay" {
  count = var.monitoring_enabled ? 1 : 0
  
  # Wait for 5 seconds
  create_duration = "5s"  

  # Ensures this sleep only starts *after* the kubectl wait is done.
  depends_on = [null_resource.wait_for_prometheus_crds]
}

#################################################
# ServiceMonitor for custom trading metrics
# We use 'kubernetes_resource' with 'override_dry_run' to bypass the CRD race.
#################################################
resource "kubernetes_resource" "trading_service_monitor" { # <-- RESOURCE TYPE CHANGED
  count = var.monitoring_enabled ? 1 : 0
  
  # CRITICAL FIX: Forces Terraform to defer GVK validation until apply time,
  # bypassing the plan-time error when the CRD is missing.
  override_dry_run = "All" # <-- CRITICAL ARGUMENT ADDED

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

  # Explicit dependency on the time_sleep ensures the CRD exists and the API server is ready.
  depends_on = [
    time_sleep.post_crd_wait_delay, # <-- DEPENDENCY MODIFIED
    data.kubernetes_namespace.trading_system
  ]
}
