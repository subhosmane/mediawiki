variable "location" {
  description = "Location where kubernetes and container registry will be created."
  type = string
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type = string
}

variable "env" {
  description = "Environment type"
  type = string
}
variable "kube_network_policy" {
  type = string
}

variable "vnetName" {
  type = string
}

variable "kube_subnet_id" {
  type = string
}
variable "rg_name" {
  description = "Resource group name where to place this cluster."
  type = string
}

variable "node_rg_name" {
  description = "Resource group name to place the node vms into"
  type = string
}

variable "kube_api_version" {
    type = string
}

variable "kube_system_node_pool_name" {
  type = string
}

variable "kube_system_version" {
    type = string
}

variable "kube_system_instance_size" {
  description = "Default pool instance size."
  type = string
}

variable "kube_system_min_node_count" {
  description = "The min number of nodes in the cluster"
  default     = "1"
}

variable "kube_system_max_node_count" {
  description = "The max number of nodes in the cluster"
  default     = "1"
}

variable "kube_system_pool_taints" {
  type = list(string)
}

variable "kube_system_max_pods" {
    type = string
}

variable "kube_system_os_disk_size_gb" {
    type = string
}

variable "kube_vnet_id" {
  description = "vnet id there nodes will be placed."
}

variable "kube_sp_app_id" {
  description = "Service principal app id used to run cluster."
  type = string
}

variable "kube_sp_app_secret" {
  description = "Client secret associated with service principal that is used to run this cluster."
  type = string
}
