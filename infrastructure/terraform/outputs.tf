output "namespaces" {
  description = "Looked-up namespaces"
  value = {
    trading_system = data.kubernetes_namespace.trading_system.metadata[0].name
    monitoring     = data.kubernetes_namespace.monitoring.metadata[0].name
    databases      = data.kubernetes_namespace.databases.metadata[0].name
  }
}

output "storage_class" {
  description = "Looked-up storage class name"
  value       = data.kubernetes_storage_class.local_storage.metadata[0].name
}

output "persistent_volumes" {
  description = "Managed persistent volumes"
  value = {
    # These now correctly point to the RESOURCE blocks
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
