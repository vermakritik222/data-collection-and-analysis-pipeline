terraform {
  required_version = ">= 1.1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.24.1"
    }
  }
  cloud {
    organization = "learningdevops_kv"
    workspaces {
      name = "testapp"
    }
  }
}

provider "azurerm" {
  subscription_id = var.az_subscription
  client_id       = var.az_client_id
  client_secret   = var.az_client_secret
  tenant_id       = var.az_tenant
  features {}
}

variable "tf_cloud_worckspace" {
  type        = string
  description = "Terraform cloud worckspace name"
}

variable "tf_cloud_orgnization" {
  type        = string
  description = "Terraform cloud orgnization name"
}

variable "az_client_id" {
  type        = string
  description = "Client ID with permissions to create resources in Azure, use env variables"
}

variable "az_client_secret" {
  type        = string
  description = "Client secret with permissions to create resources in Azure, use env variables"
}

variable "az_subscription" {
  type        = string
  description = "Client ID subscription, use env variables"
}

variable "az_tenant" {
  type        = string
  description = "Client ID Azure AD tenant, use env variables"
}
