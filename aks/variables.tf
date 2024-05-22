#general

variable "region" {
  type    = string
  default = "South Africa North"
}

variable "env" {
  type        = string
  description = "The environment i.e prod, dev etc"
}

variable "dns_zone" {
  type    = string
  default = "azure.rentrahisi.co.ke"
}

#vpc
variable "address_spaces" {
  type = map(list(string))
  default = {
    "dev"  = ["10.0.0.0/16"]
    "prod" = ["10.1.0.0/16"]
  }
}

variable "subnet_prefixes" {
  type = map(list(string))
  default = {
    "dev"  = ["10.0.0.0/20", "10.0.16.0/20"]
    "prod" = ["10.1.32.0/20", "10.1.48.0/20"]
  }
}

#k8s

variable "cluster_created" {
  description = "create applications such as argocd only when the eks cluster has already been created"
  default = {
    "dev"  = false
    "prod" = false
  }
}

variable "cluster_not_terminated" {
  default = {
    "dev"  = true
    "prod" = false
  }
}

variable "cluster_name" {
  type    = string
  default = "compute"
}

variable "default_node_pool" {
  type = any
  default = {
    "dev" = {
      agents_pool_name          = "workers"
      agents_size               = "Standard_B4als_v2"
      enable_auto_scaling       = true
      agents_min_count          = 2
      agents_max_count          = 3
      os_disk_size_gb           = 100
      agents_availability_zones = [1, 2]
      agents_count              = null
      agents_max_pods           = 50
    }
  }
}

variable "net_profile_service_cidr" {
  type        = string
  description = "The Network Range used by the Kubernetes service"
  default     = "192.168.1.0/24"
}

variable "net_profile_dns_service_ip" {
  type        = string
  description = "IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)"
  default     = "192.168.1.2"
}

variable "automatic_channel_upgrade" {
  type = map(string)
  default = {
    "dev"  = "stable"
    "prod" = null
  }
}

variable "log_analytics_workspace_enabled" {
  default = false
}

variable "maintenance_window" {
  description = "Maintenance window configuration for the node pool"
  type        = any
  default = {
    allowed = [
      {
        day   = "Saturday"
        hours = [21]
      }
    ]
    not_allowed = []
  }
}

# 2nd week of every month on Sat
variable "maintenance_window_auto_upgrade" {
  description = "Maintenance window configuration for auto-upgrade"
  type        = any
  default = {
    frequency    = "RelativeMonthly"
    day_of_week  = "Saturday"
    week_index   = "Second"
    duration     = 4
    start_time   = "21:00"
    interval     = 1
    start_date   = null
    utc_offset   = "+00:00"
    not_allowed  = null
    day_of_month = null
  }
}

# 3rd week of every month on Sat
variable "maintenance_window_node_os" {
  description = "Maintenance window configuration for auto-upgrade"
  type        = any
  default = {
    frequency    = "RelativeMonthly"
    day_of_week  = "Saturday"
    week_index   = "Third"
    duration     = 4
    start_time   = "21:00"
    interval     = 1
    start_date   = null
    utc_offset   = "+00:00"
    not_allowed  = null
    day_of_month = null
  }
}

variable "sku_tier" {
  type        = map(string)
  description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free, Standard and Premium"
  default = {
    "dev"  = "Free"
    "prod" = "Standard"
  }
}

variable "rbac_aad_azure_rbac_enabled" {
  default = false
}

variable "rbac_aad_managed" {
  default = true
}

variable "rbac_aad" {
  description = "Is Azure Active Directory integration enabled?"
  default     = true
}

variable "admins" {
  type        = list(string)
  description = "IDs of admin users"
  default     = ["d8c3537f-4698-4d55-b1fd-2c4ea671a5ae"]
}

variable "net_profile_outbound_type" {
  type    = string
  default = "loadBalancer"
}

variable "network_plugin" {
  type    = string
  default = "azure"
}

variable "gateway_autoscaling" {
  type = map(number)
  default = {
    "min_capacity" = 1
    "max_capacity" = 20
  }
}

variable "letsencrypt_envir" {
  type        = list(string)
  description = "IDs of admin users"
  default     = ["d8c3537f-4698-4d55-b1fd-2c4ea671a5ae"]
}

variable "letsencrypt_email" {
  type        = string
  description = "email to contact you about expiring certificates & issues"
}

variable "letsencrypt_environment" {
  type = map(string)
  default = {
    "dev"  = "https://acme-staging-v02.api.letsencrypt.org/directory"
    "prod" = "https://acme-v02.api.letsencrypt.org/directory"
  }
}

# ELK and Grafana

variable "elastic_password" {
  type = string
}

variable "grafana_user" {
  type = string
}

variable "grafana_password" {
  type = string
}

variable "slack_incoming_webhook_url" {
  type = string
}

variable "elastic" {
  type = any
  default = {
    "dev" = {
      replicas           = 2
      minimumMasterNodes = 2
      pv_storage         = "5Gi"
    }
  }
}

variable "kibana" {
  type = any
  default = {
    "dev" = {
      dns_name = "kibana"
    }
  }
}

variable "prometheus" {
  type = any
  default = {
    "dev" = {
      pv_storage = "10Gi"
      retention  = "30d"
    }
  }
}

variable "grafana" {
  type = any
  default = {
    "dev" = {
      dns_name         = "grafana"
      pv_storage       = "1Gi"
      storageClassName = "default"
    }
  }
}

# ArgoCD

variable "argocd" {
  type = any
  default = {
    "dev" = {
      dns_name  = "dev-argocd"
      argo_repo = "git@github.com:leroykayanda"
    }
  }
}

variable "argo_ssh_private_key" {
  description = "The SSH private key. ArgoCD uses this to authenticate to the repos in your github org"
  type        = string
}

variable "argo_slack_token" {
  type        = string
  default     = "xoxb-redacted"
  description = "Used by ArgoCD notifications to send alerts to Slack"
}

variable "argocd_image_updater_values" {
  type        = list(string)
  description = "specifies authentication details needed by argocd image updater"
  default = [
    <<EOF
config:
  registries:
    - name: ACR demo-app
      api_url: https://devdemoapp.azurecr.io
      prefix: devdemoapp.azurecr.io
      ping: yes
      credentials: pullsecret:argocd/argocd-image-updater-acr-demo-app
EOF
  ]
}
