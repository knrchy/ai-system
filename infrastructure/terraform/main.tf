terraform {
  required_version = ">= 1.0"
  
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.28"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    time = {
      source = "hashicorp/time"
      version = "~> 0.9"
    }
    # ADD THIS BLOCK
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14" # Use a recent stable version
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

# ADD THIS PROVIDER CONFIGURATION
provider "kubectl" {
  apply_timeouts = {
    # Increase the apply timeout for ServiceMonitor
    "monitoring.coreos.com/v1/ServiceMonitor" = "5m" 
  }
  # This tells the kubectl provider where to find the kubeconfig file
  kubeconfig = "~/.kube/config" 
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

#---------------------------------------------------------------------
# Data Sources: For resources that support lookups.
#---------------------------------------------------------------------
data "kubernetes_namespace" "trading_system" {
  metadata {
    name = "trading-system"
  }
}

data "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

data "kubernetes_namespace" "databases" {
  metadata {
    name = "databases"
  }
}

data "kubernetes_storage_class" "local_storage" {
  metadata {
    name = "local-storage"
  }
}

#---------------------------------------------------------------------
# Managed Resources: Persistent Volumes (PVs)
#---------------------------------------------------------------------
resource "kubernetes_persistent_volume" "data_storage" {
  metadata {
    name = "trading-data-pv"
    labels = {
      "app"  = "trading-system"
      "type" = "local"
    }
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      host_path {
        path = "/mnt/trading-data"
        type = "DirectoryOrCreate"
      }
    }
    storage_class_name = data.kubernetes_storage_class.local_storage.metadata[0].name
  }
}

resource "kubernetes_persistent_volume" "models_storage" {
  metadata {
    name = "models-pv"
    labels = {
      "app"  = "trading-system"
      "type" = "local"
    }
  }
  spec {
    capacity = {
      storage = "40Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      host_path {
        path = "/mnt/models"
        type = "DirectoryOrCreate"
      }
    }
    storage_class_name = data.kubernetes_storage_class.local_storage.metadata[0].name
  }
}
