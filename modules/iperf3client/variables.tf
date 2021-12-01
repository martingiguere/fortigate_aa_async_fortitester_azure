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

variable "storage_account_endpoint" {
    type = string
    description = "Storage Account for Boot Diagnostics"
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

variable "ipf_accelerated_networking" {
  type        = bool
  description = "Enables Accelerated Networking for the network interfaces of the Iperf3 Client"
}


variable "ipf_ipaddress_offset" {
  type        = number
  description = "Iperf3 Client 1 IP offset from subnet cidr"
  default =  10
}

variable "ipf_image_sku" {
  type        = string
  description = "Iperf3 Client image SKU"
}

variable "ipf_username" {
  type        = string
  description = "Iperf3 Client admin username"
}

variable "ipf_number_deployed" {
  type        = number
  description = "Number of Iperf3 Client VM to deploy"
}


variable "ipf_password" {
  type        = string
  description = "Iperf3 Client admin password"
}

variable "ipf_public_ip" {
  type = bool
  description = "Deploy and associate Public IP with Iperf3 Client VM"
  default = true
}

variable "ipf_subnet_number" {
  type        = number
  description = "Subnet number to deploy the Iperf3 Client VM(s)"
  default     = 4
}

variable "ipf_version" {
  type        = string
  description = "Iperf3 Client Ubuntu version"
}

variable "ipf_vmsize" {
  type        = string
  description = "Iperf3 Client VM size"
}