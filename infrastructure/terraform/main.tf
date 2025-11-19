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
# Data Sources: Look up existing resources without managing them
#---------------------------------------------------------------------

# Look up the namespaces that were created by your YAML file.
# Terraform will now read their properties but will never try to create or delete them.
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

# Look up the existing Storage Class
data "kubernetes_storage_class" "local_storage" {
  metadata {
    name = "local-storage"
  }
}

# Look up the existing Persistent Volumes
data "kubernetes_persistent_volume" "data_storage" {
  metadata {
    name = "trading-data-pv"
  }
}

data "kubernetes_persistent_volume" "models_storage" {
  metadata {
    name = "models-pv"
  }
}
