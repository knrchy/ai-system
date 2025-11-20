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
# Using kubectl_manifest is the most robust way to handle CRD dependencies.
#################################################
resource "kubectl_manifest" "trading_service_monitor" { # <-- FINAL RESOURCE TYPE
  count = var.monitoring_enabled ? 1 : 0
  
  # The manifest is applied directly as a YAML string
  yaml_body = yamlencode(
    {
      apiVersion = "monitoring.coreos.com/v1"
      kind       = "ServiceMonitor"
      metadata = {
        name      = "trading-metrics"
        namespace = data.kubernetes_namespace.trading_system.metadata[0].name
        labels = {
          release = "prometheus"
        }
      }
      spec = {
        selector = {
          matchLabels = {
            app = "trading-api"
          }
        }
        endpoints = [
          {
            port     = "metrics"
            interval = "30s"
            path     = "/metrics"
          }
        ]
      }
    }
  )

  # Explicit dependency on the time_sleep ensures the CRD exists and the API server is ready.
  depends_on = [
    time_sleep.post_crd_wait_delay, 
    data.kubernetes_namespace.trading_system
  ]
}
