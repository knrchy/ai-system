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

# Namespaces
resource "kubernetes_namespace" "trading_system" {
  metadata {
    name = "trading-system"
    labels = {
      name        = "trading-system"
      environment = var.environment
    }
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

#resource "kubernetes_namespace" "monitoring" {
  #metadata {
    #name = "monitoring"
    #labels = {
      #name        = "monitoring"
      #environment = var.environment
    #}
  #}
#
  #lifecycle {
    #ignore_changes = [metadata]
  #}
#}

resource "kubernetes_namespace" "databases" {
  metadata {
    name = "databases"
    labels = {
      name        = "databases"
      environment = var.environment
    }
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

# Storage Class for local storage
resource "kubernetes_storage_class" "local_storage" {
  metadata {
    name = "local-storage"
  }
  storage_provisioner = "kubernetes.io/no-provisioner"
  volume_binding_mode = "WaitForFirstConsumer"

  lifecycle {
    ignore_changes = [metadata]
  }
}

# Persistent Volumes
resource "kubernetes_persistent_volume" "data_storage" {
  metadata {
    name = "trading-data-pv"
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
    storage_class_name = kubernetes_storage_class.local_storage.metadata[0].name
  }
}

resource "kubernetes_persistent_volume" "models_storage" {
  metadata {
    name = "models-pv"
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
    storage_class_name = kubernetes_storage_class.local_storage.metadata[0].name
  }
}
