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
  default = "compute"
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

# #argocd
# variable "argo_annotations" {
#   type = map(map(string))
#   default = {
#     "dev" = {
#       "notifications.argoproj.io/subscribe.on-health-degraded.slack" = "rentrahisi"
#       "argocd-image-updater.argoproj.io/image-list"                  = "repo=735265414519.dkr.ecr.eu-west-1.amazonaws.com/dev-demo-app"
#       "argocd-image-updater.argoproj.io/repo.update-strategy"        = "latest"
#       "argocd-image-updater.argoproj.io/myimage.ignore-tags"         = "latest"
#     },
#     "prod" = {
#     }
#   }
# }

# variable "argo_repo" {
#   type        = string
#   description = "repo containing manifest files"
#   default     = "git@github.com:leroykayanda/eks-cluster.git"
# }

# variable "argo_target_revision" {
#   description = "branch containing app code"
#   type        = map(string)
#   default = {
#     "dev"  = "main"
#     "prod" = ""
#   }
# }

# variable "argo_path" {
#   type        = map(string)
#   description = "path of the manifest files"
#   default = {
#     "dev"  = "demo-app/manifests/overlays/dev"
#     "prod" = ""
#   }
# }

# variable "argo_server" {
#   type        = map(string)
#   description = "dns name of the argocd server"
#   default = {
#     "dev"  = "dev-argo.rentrahisi.co.ke:443"
#     "prod" = ""
#   }
# }
