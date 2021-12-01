variable "resource_group_name" {
    type = string
    description = "Resource Group Name"
}

variable "location" {
    type = string
    description = "Azure Location"
}

variable "vnet" {
  type = string
  description = "VNET CIDR Block"
}

variable "subnets_cidr" {
  type        = map(string)
  description = "Subnets CIDR of the VNET"
}

variable "lb_internal_ipaddress" {
  type = string
  description = "internal load balancer IP"
}

variable "prefix" {
  type = string    
  description = "Added name to each deployed resource"
}