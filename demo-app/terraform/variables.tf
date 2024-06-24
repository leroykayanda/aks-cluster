#general

variable "service" {
  type        = string
  description = "The name of the product or service being built"
  default     = "demo-app"
}

variable "region" {
  type    = string
  default = "South Africa North"
}

variable "resource_group" {
  type = map(string)
  default = {
    "dev"  = "aks-dev"
    "prod" = ""
  }
}

variable "env" {
  type        = string
  description = "The environment i.e prod, dev etc"
}

# k8s
variable "cluster_name" {
  type    = string
  default = "services"
}

# ACR 
variable "acr_sku" {
  type = map(string)
  default = {
    "dev"  = "Basic"
    "prod" = ""
  }
}

variable "acr_admin_enabled" {
  default = true
}

# argocd

variable "argo_annotations" {
  type = map(map(string))
  default = {
    "dev" = {
      "notifications.argoproj.io/subscribe.on-health-degraded.slack" = "rentrahisi"
      "argocd-image-updater.argoproj.io/image-list"                  = "repo=devdemoapp.azurecr.io/devdemoapp"
      "argocd-image-updater.argoproj.io/repo.update-strategy"        = "newest-build"
      "argocd-image-updater.argoproj.io/myimage.ignore-tags"         = "latest"
    },
    "prod" = {
    }
  }
}

variable "argocd" {
  type = any
  default = {
    "dev" = {
      repo_url        = "git@github.com:leroykayanda/aks-cluster.git"
      target_revision = "main"
      path            = "demo-app/helm-charts/app"
      server          = "dev-argocd.azure.rentrahisi.co.ke:443"
      value_files = [
        "../base-values.yaml",
        "../dev-values.yaml"
      ]
    }
  }
}
