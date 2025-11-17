# Environment Configuration
environment     = "development"
cluster_name    = "trading-ai-cluster"

# Monitoring
monitoring_enabled = true

# Storage
data_storage_size   = "5Gi"
models_storage_size = "40Gi"

# Kubernetes Config
kubeconfig_path = "~/.kube/config"

# Resource Limits
default_cpu_limit    = "1000m"
default_memory_limit = "2Gi"
