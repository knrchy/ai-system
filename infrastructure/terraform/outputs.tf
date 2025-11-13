output "namespaces" {
  description = "Created namespaces"
  value = {
    trading_system = kubernetes_namespace.trading_system.metadata[0].name
    monitoring     = kubernetes_namespace.monitoring.metadata[0].name
    databases      = kubernetes_namespace.databases.metadata[0].name
  }
}

output "storage_class" {
  description = "Storage class name"
  value       = kubernetes_storage_class.local_storage.metadata[0].name
}

output "persistent_volumes" {
  description = "Created persistent volumes"
  value = {
    data_pv   = kubernetes_persistent_volume.data_storage.metadata[0].name
    models_pv = kubernetes_persistent_volume.models_storage.metadata[0].name
  }
}

output "cluster_info" {
  description = "Cluster information"
  value = {
    name        = var.cluster_name
    environment = var.environment
  }
}

output "storage_paths" {
  description = "Host storage paths"
  value = {
    data_path   = "/mnt/trading-data"
    models_path = "/mnt/models"
  }
}
