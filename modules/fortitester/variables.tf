variable "resource_group_name" {
    type = string
    description = "Resource Group Name"
}

variable "location" {
    type = string
    description = "Azure Location"
}

variable "lb_deployed" {
  type = bool
  description = "Azure Public LB deployed"
  default = true
}

variable "lb_external_id" {
  type = string
  description = "Azure Public LB id to optionally use to create NAT rules for management of FortiTester"
  default = null
}

variable "storage_account_endpoint" {
    type = string
    description = "Storage Account for Boot Diagnostics"
}

variable "vnet" {
  type = string
  description = "VNET CIDR Block"
}

variable "subnets_ids" {
  type        = map(string)
  description = "Subnets IDs"
}

variable "subnets_cidr" {
  type        = map(string)
  description = "Subnets of the VNET"
}

variable "prefix" {
  type = string    
  description = "Added name to each deployed resource"
}

variable "fts_accelerated_networking" {
  type        = bool
  description = "Enables Accelerated Networking for the network interfaces of the FortiTester VM"
}


variable "fts_ipaddress_offset" {
  type        = number
  description = "FortiTester VM 1 IP offset from subnet cidr"
  default =  10
}

variable "fts_image_sku" {
  type        = string
  description = "FortiTester VM image SKU"
}

variable "fts_username" {
  type        = string
  description = "FortiTester VM admin username"
}

variable "fts_number_interfaces" {
  type        = number
  description = "Number of FortiTester VM to deploy"
}


variable "fts_password" {
  type        = string
  description = "FortiTester VM admin password"
}

variable "fts_public_ip" {
  type = bool
  description = "Deploy and associate Public IP with FortiTester VM"
  default = true
}

variable "fts_subnet_number" {
  type        = number
  description = "Subnet number to deploy the FortiTester VM"
}

variable "fts_version" {
  type        = string
  description = "FortiTester version"
}

variable "fts_vmsize" {
  type        = string
  description = "FortiTester VM size"
}