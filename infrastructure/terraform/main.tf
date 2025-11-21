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
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14" 
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# The provider "kubectl" block has been removed, relying on shared kubeconfig/environment settings.

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
  # This PV definition is required for the PVC to bind. 
  # It must be applied BEFORE the Deployment.
  
  # The local resource name now matches your original setup.
  metadata {
    name = "trading-data-pv"
    labels = {
      "app"  = "trading-system"
      "type" = "local"
    }
  }

  spec {
    # CRITICAL: Capacity must match the request in the PVC (5Gi)
    capacity = {
      storage = "5Gi"
    }
    
    # Must match the PVC access mode. Using ReadWriteMany (RWM) allows 
    # the two Pod replicas (on the same node) to share this volume.
    access_modes = ["ReadWriteMany"]
    
    # CRITICAL: The hostPath ties this PV to the local filesystem on k8sworker3.
    persistent_volume_source {
      host_path {
        path = "/mnt/trading-data"
        type = "DirectoryOrCreate"
      }
    }
    
    # CRITICAL: Use the robust Data Source reference, matching your main.tf
    storage_class_name = data.kubernetes_storage_class.local_storage.metadata[0].name
    
    # Set to Retain to prevent Kubernetes from deleting the underlying 
    # directory and data if the PV is deleted.
    persistent_volume_reclaim_policy = "Retain"
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
