variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
  default     = "trading-ai-cluster"
}

variable "monitoring_enabled" {
  description = "Enable monitoring stack"
  type        = bool
  default     = true
}

variable "data_storage_size" {
  description = "Size of data storage in Gi"
  type        = string
  default     = "5Gi"
}

variable "models_storage_size" {
  description = "Size of models storage in Gi"
  type        = string
  default     = "40Gi"
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "default_cpu_limit" {
  description = "Default CPU limit for containers"
  type        = string
  default     = "2000m"
}

variable "default_memory_limit" {
  description = "Default memory limit for containers"
  type        = string
  default     = "2Gi"
}

variable "enable_gpu" {
  description = "Enable GPU support for ML workloads"
  type        = bool
  default     = false
}

variable "backup_enabled" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}
