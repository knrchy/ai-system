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

#---------------------------------------------------------------------
# Data Sources: For resources that support lookups.
# Terraform will read these but never create or destroy them.
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
# Managed Resources: For resources that MUST be managed.
# We will use 'terraform import' to adopt the existing ones.
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
    # Note: We now refer to the DATA source for the storage class name
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
    # Note: We now refer to the DATA source for the storage class name
    storage_class_name = data.kubernetes_storage_class.local_storage.metadata[0].name
  }
}
