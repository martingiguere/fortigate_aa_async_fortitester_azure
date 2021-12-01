variable "resource_group_name" {
    type = string
    description = "Resource Group Name"
}

variable "location" {
    type = string
    description = "Azure Location"
}

variable "my_public_ip" {
    type = string
    description = "identify the public ip of the terraform execution environment"
}

variable "public_ip_address_elb_ip" {
    type = string
    description = "FrontEnd Public IP of the Load Balancer with workload LB Rules "
}

variable "vnet" {
  type = string
  description = "VNET CIDR Block"
}

variable "storage_account_endpoint" {
    type = string
    description = "Storage Account for Boot Diagnostics"
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

variable "lb_internal_ipaddress" {
  type = string
  description = "internal load balancer IP"
}

variable "prefix" {
  type = string    
  description = "Added name to each deployed resource"
}

variable "fgt_api_key" {
  type = string
  description = "FortiGate REST API key"
}


variable "fgt_accelerated_networking" {
  type        = bool
  description = "Enables Accelerated Networking for the network interfaces of the FortiGate"
}

variable "fgt_byol_license_files" {
  type        = map(string)
  description = "FortiGate BYOL license files"
}

variable "fgt_flexvm_license_tokens" {
  type        = map(string)
  description = "FortiGate BYOL FLEXVM license tokens"
}

variable "fgt_ipaddress_offset" {
  type        = number
  description = "FortiGate 1 IP offset from subnet cidr"
  default =  5
}

variable "fgt_image_sku" {
  type        = string
  description = "FortiGate image SKU"
}

variable "fgt_ssh_public_key_file" {
  type        = string
  description = "FortiGate SSH public key file"
}

variable "fgt_username" {
  type        = string
  description = "FortiGate admin username"
}

variable "fgt_number_deployed" {
  type        = number
  description = "Number of FortiGate VM to deploy"
}


variable "fgt_password" {
  type        = string
  description = "FortiGate admin password"
}

variable "fgt_version" {
  type        = string
  description = "FortiGate FortiOS version"
}

variable "fgt_vmsize" {
  type        = string
  description = "FortiGate VM size"
}

variable "web_ipaddress_offset" {
  type        = number
  description = "Web Server Instance 1 IP offset from subnet cidr"
}

variable "web_subnet_number" {
  type        = number
  description = "Web Server Instance(s) Subnet number)"
}