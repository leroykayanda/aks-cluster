terraform {
  backend "remote" {
    organization = "RentRahisi"

    workspaces {
      prefix = "aks-"
    }
  }

  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.99.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.48.0"
    }

    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.0.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }

  }
}
