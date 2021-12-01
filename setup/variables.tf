##############################################################################################################
# Static variables
##############################################################################################################

# Prefix for all resources created for this deployment in Microsoft Azure
variable "PREFIX" {
  type        = string
  description = "Added name to each deployed resource"
  default     = "fgaa"
}

variable "LOCATION" {
  type        = string
  description = "Azure region"
}

variable "FGT_USERNAME" {
  type        = string  
}

variable "FGT_PASSWORD" {
  type        = string
}

variable "FGT_API_KEY" {
  type        = string
  default     = "DEFINEYOUROWNVERYLONGKNOWNKEYY"
  description = "FortiGate REST API key"
}

##############################################################################################################
# FortiGate license type
##############################################################################################################
variable "FGT_IMAGE_SKU" {
  type        = string
  description = "Azure Marketplace default image sku hourly (PAYG 'fortinet_fg-vm_payg_20190624') or byol (Bring your own license 'fortinet_fg-vm')"
  default     = "fortinet_fg-vm_payg_20190624"
}

variable "FGT_VERSION" {
  type        = string
  description = "FortiGate version by default the 'latest' available version in the Azure Marketplace is selected"
  default     = "latest"
}


variable "FGT_BYOL_LICENSE_FILES" {
  type        = map(string)
  description = "FortiGate BYOL license files, for example license1.lic for FortiGate1"
  default = {
    "1" = ""
    "2" = ""
    "3" = ""
    "4" = ""
  }
}

variable "FGT_FLEXVM_LICENSE_TOKENS" {
  type        = map(string)
  description = "FortiGate BYOL FLEXVM license tokens, for example 9ACB78031DF242B1A966 for FortiGate1"
  default = {
    "1" = ""
    "2" = ""
    "3" = ""
    "4" = ""
  }
}

variable "FGT_SSH_PUBLIC_KEY_FILE" {
  type    = string
  default = ""
}

##############################################################################################################
# Accelerated Networking
# Only supported on specific VM series and CPU count: D/DSv2, D/DSv3, E/ESv3, F/FS, FSv2, and Ms/Mms
# https://azure.microsoft.com/en-us/blog/maximize-your-vm-s-performance-with-accelerated-networking-now-generally-available-for-both-windows-and-linux/
##############################################################################################################
variable "FGT_ACCELERATED_NETWORKING" {
  type        = bool
  description = "Enables Accelerated Networking for the network interfaces of the FortiGate"
  default     = true
}


##############################################################################################################
#
# Number of FortiGate Firewall Instances to deploy
#
##############################################################################################################

variable "FGT_NUMBER_DEPLOYED" {
  type        = number
  description = "Number of FGT instances"
  default     =  4
}



variable "vnet" {
  type        = string
  description = ""
  default     = "172.16.136.0/22"
}

variable "subnets_cidr" {
  type        = map(string)
  description = ""
  default = {
    "1" = "172.16.136.0/26"   # External
    "2" = "172.16.136.64/26"  # Internal
    "3" = "172.16.136.128/26" # Mid
    "4" = "172.16.137.0/24"   # Protected a
    "5" = "172.16.138.0/24"   # Protected b
  }
}

variable "fgt_ipaddress_offset" {
  type        = number
  description = "FortiGate 1 IP offset from subnet cidr"
  default     =  5
}

variable "fts_ipaddress_offset" {
  type        = number
  description = "FortiTester IP offset from subnet cidr"
  default     =  10
}

variable "fgt_vmsize" {
  type    = string
#  default = "Standard_D8_v3"
#  default = "Standard_D8s_v3"
  default = "Standard_D16s_v4"  
#  default = "Standard_F4s"  
}

variable "lb_internal_ipaddress" {
  type        = string
  description = ""
  default     = "172.16.136.68"
}

variable "lb_deployed" {
  type        = bool
  description = "Should the Azure Public Load Balancers be deployed"
  default     = true
}

variable "web_ipaddress_offset" {
  type        = number
  description = "Web Server Instance 1 IP offset from subnet cidr"
  default     =  20
}

variable "web_subnet_number" {
  type        = number
  description = "Web Server Instance(s) Subnet number)"
  default     =  5
}

