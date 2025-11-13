#################################################
# Wait for Prometheus CRDs to be available
#################################################
resource "null_resource" "wait_for_crd" {
  count = var.monitoring_enabled ? 1 : 0

  # Trigger ensures wait only happens after Helm release is created
  triggers = {
    release_name = helm_release.prometheus[0].name
  }

  provisioner "local-exec" {
    command = "sleep 30" # Wait for 30 seconds to allow the API server to catch up
  }

  depends_on = [helm_release.prometheus]
}

#################################################
# Helm Release: Prometheus + Grafana + Alertmanager
#################################################
resource "helm_release" "prometheus" {
  count       = var.monitoring_enabled ? 1 : 0
  name        = "prometheus"
  repository  = "https://prometheus-community.github.io/helm-charts"
  chart       = "kube-prometheus-stack"
  namespace   = kubernetes_namespace.monitoring.metadata[0].name
  version     = "51.0.0"

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
        enabled        = true
        adminPassword  = "admin" # Change in production!
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

  depends_on = [kubernetes_namespace.monitoring]
}

#################################################
# ServiceMonitor for custom trading metrics
#################################################
resource "kubernetes_manifest" "trading_service_monitor" {
  count = var.monitoring_enabled ? 1 : 0

  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "trading-metrics"
      namespace = kubernetes_namespace.trading_system.metadata[0].name
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

  # Explicit dependency on the wait resource
  depends_on = [
    null_resource.wait_for_crd,
    kubernetes_namespace.trading_system
  ]
}
