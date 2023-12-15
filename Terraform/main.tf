terraform {
  required_version = "~> 1.2.2"
  backend "azurerm" {}
  required_providers {
    azurerm = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = "=3.50.0"
    }
}
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "random_integer" "kube_seq" {
  min = 100
  max = 999
}

resource "tls_private_key" "aks_linux_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = upper(var.cluster_name)
  kubernetes_version  = var.kube_api_version
  location            = var.location
  resource_group_name = var.rg_name
  node_resource_group = var.node_rg_name
  dns_prefix          = lower(var.cluster_name)

  default_node_pool {
    name  = var.kube_system_node_pool_name
    type = "VirtualMachineScaleSets"
    orchestrator_version = var.kube_system_version
    node_count = 1
    vm_size = var.kube_system_instance_size
    os_disk_size_gb = var.kube_system_os_disk_size_gb
  }

   service_principal {
    client_id = var.kube_sp_app_id
    client_secret = var.kube_sp_app_secret
  }
}