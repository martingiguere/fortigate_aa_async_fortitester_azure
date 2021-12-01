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

variable "web_accelerated_networking" {
  type        = bool
  description = "Enables Accelerated Networking for the network interfaces of the Web Server Workload"
}


variable "web_ipaddress_offset" {
  type        = number
  description = "Web Server Workload 1 IP offset from subnet cidr"
  default =  10
}

variable "web_image_sku" {
  type        = string
  description = "Web Server Workload image SKU"
}

variable "web_username" {
  type        = string
  description = "Web Server Workload admin username"
}

variable "web_number_deployed" {
  type        = number
  description = "Number of Web Server Workload VM to deploy"
}


variable "web_password" {
  type        = string
  description = "Web Server Workload admin password"
}

variable "web_subnet_number" {
  type        = number
  description = "Subnet number to deploy the Web Server Wokload VM(s)"
  default     = 4
}

variable "web_version" {
  type        = string
  description = "Web Server Workload Ubuntu version"
}

variable "web_vmsize" {
  type        = string
  description = "Web Server Workload VM size"
}