variable "fgt_number_deployed" {
  type        = number
  description = "Number of FortiGate VM(s) to deploy"
}


variable "fgtifcext_id" {
  description = "External Interfaces of the FortiFate VMs"
}

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
  description = "Subnets of the VNET"
}

variable "subnet_subnet1_id" {
  type = string
  description = "Subnet Subnet1 ID"
}

variable "subnet_subnet2_id" {
  type = string
  description = "Subnet Subnet2 ID"
}

variable "subnet_subnet3_id" {
  type = string
  description = "Subnet Subnet3 ID"
}

variable "subnet_subnet4_id" {
  type = string
  description = "Subnet Subnet4 ID"
}

variable "subnet_subnet5_id" {
  type = string
  description = "Subnet Subnet5 ID"
}

variable "prefix" {
  type = string    
  description = "Added name to each deployed resource"
}

