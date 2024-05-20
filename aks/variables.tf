#general

variable "region" {
  type    = string
  default = "South Africa North"
}

variable "env" {
  type        = string
  description = "The environment i.e prod, dev etc"
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
      agents_min_count          = 1
      agents_max_count          = 2
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
      replicas           = 1
      minimumMasterNodes = 1
      pv_storage         = "5Gi"
    }
  }
}

variable "kibana" {
  type = any
  default = {
    "dev" = {
      dns_name = "kibana"
      dns_zone = "azure.rentrahisi.co.ke"
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
      dns_zone         = "azure.rentrahisi.co.ke"
      pv_storage       = "1Gi"
      storageClassName = "default"
    }
  }
}

# #k8s


# variable "argo_load_balancer_attributes" {
#   type = map(string)
#   default = {
#     "dev"  = "access_logs.s3.enabled=true,access_logs.s3.bucket=dev-rentrahisi-eks-cluster-alb-access-logs,idle_timeout.timeout_seconds=300"
#     "prod" = ""
#   }
# }

# variable "argo_target_group_attributes" {
#   type = map(string)
#   default = {
#     "dev"  = "deregistration_delay.timeout_seconds=5"
#     "prod" = ""
#   }
# }

# variable "argo_tags" {
#   type = map(string)
#   default = {
#     "dev"  = "Environment=dev,Team=devops"
#     "prod" = ""
#   }
# }

# variable "company_name" {
#   type        = string
#   description = "To make ELB access log bucket name unique"
#   default     = "rentrahisi"
# }

# #argoCD

# variable "zone_id" {
#   type        = string
#   default     = "Z10421303ISFAWMPOGQET"
#   description = "Route53 zone to create ArgoCD dns name in"
# }

# variable "certificate_arn" {
#   type        = string
#   default     = "arn:aws:acm:eu-west-1:735265414519:certificate/eab25873-8e9c-4895-bd1a-80a1eac6a09e"
#   description = "ACM certificate to be used by ingress"
# }

# variable "argo_domain_name" {
#   type        = map(string)
#   description = "domain name for argocd ingress"
#   default = {
#     "dev"  = "dev-argo.rentrahisi.co.ke"
#     "prod" = ""
#   }
# }

# variable "argo_ssh_private_key" {
#   description = "The SSH private key. ArgoCD uses this to authenticate to the repos in your github org"
#   type        = string
# }

# variable "argo_repo" {
#   type        = string
#   description = "repo where manifest files needed by argocd are stored"
#   default     = "git@github.com:leroykayanda"
# }

# variable "argo_slack_token" {
#   type        = string
#   default     = "xoxb-redacted"
#   description = "Used by ArgoCD notifications to send alerts to Slack"
# }

# variable "argocd_image_updater_values" {
#   type        = list(string)
#   description = "specifies authentication details needed by argocd image updater"
#   default = [
#     <<EOF
# config:
#   registries:
#     - name: ECR
#       api_url: https://735265414519.dkr.ecr.eu-west-1.amazonaws.com
#       prefix: 735265414519.dkr.ecr.eu-west-1.amazonaws.com
#       ping: yes
#       insecure: no
#       credentials: ext:/scripts/ecr-login.sh
#       credsexpire: 9h
# authScripts:
#   enabled: true
#   scripts:
#     ecr-login.sh: |
#       #!/bin/sh
#       aws ecr --region eu-west-1 get-authorization-token --output text --query 'authorizationData[].authorizationToken' | base64 -d
# EOF
#   ]
# }
