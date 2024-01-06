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

# Virtual Network
resource "azurerm_virtual_network" "aks_vnet" {
  name                = var.vnetName
  address_space       = var.vnet_address  # Change the address space as needed
  location            = var.location
  resource_group_name = var.rg_name
}

# Subnet
resource "azurerm_subnet" "aks_subnet" {
  name                 = ""
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes    = var.subnet_address  # Change the subnet address space as needed
}

# Output the VNet ID and Subnet ID for AKS configuration
output "vnet_id" {
  value = azurerm_virtual_network.aks_vnet.id
}

output "subnet_id" {
  value = azurerm_subnet.aks_subnet.id
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
    vnet_subnet_id  = azurerm_subnet.aks_subnet.id
  }

  network_profile {
    network_plugin = var.network_plugin
    network_plugin_mode = var.network_plugin_mode
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
    pod_cidr  = var.pod_cidr
    docker_bridge_cidr = var.docker_bridge_cidr

    load_balancer_sku = var.load_balancer_sku
  }

  private_cluster_enabled =  var.private_cluster_enabled

  service_principal {
    client_id = var.kube_sp_app_id
    client_secret = var.kube_sp_app_secret
  }
}