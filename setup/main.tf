##############################################################################################################
# Deployment in Microsoft Azure
##############################################################################################################

terraform {
  required_version = ">= 0.14"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.79.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# identify the public ip of the terraform execution environment
data "http" "my_public_ip" {
  url = "https://api.ipify.org"
}
/*
data "http" "my_public_ip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}
*/

locals {
  //my_public_ip = jsondecode(data.http.my_public_ip.body)
  my_public_ip = chomp(data.http.my_public_ip.body)
}

output "my_ip_addr" {
  //value = local.my_public_ip.ip
  value = local.my_public_ip
}






##############################################################################################################
# Accept the Terms license for the FortiGate Marketplace image
# This is a one-time agreement that needs to be accepted per subscription
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/marketplace_agreement
##############################################################################################################
#resource "azurerm_marketplace_agreement" "fortinet" {
#  publisher = "fortinet"
#  offer     = "fortinet_fortigate-vm_v5"
#  plan      = var.FGT_IMAGE_SKU
#}




##############################################################################################################
# Resource Group
##############################################################################################################

resource "azurerm_resource_group" "resourcegroup" {
  name     = "${var.PREFIX}-RG"
  location = var.LOCATION
}

##############################################################################################################


# Generate random string for storage account
resource "random_string" "randomstring" {
  length  = 8
  special = "false"
}



# Storage account
resource "azurerm_storage_account" "storageaccount" {
  name                     = lower(join("", [random_string.randomstring.result, "storageaccount"]))
  resource_group_name      = azurerm_resource_group.resourcegroup.name
  location                 = var.LOCATION
  account_replication_type = "LRS"
  account_tier             = "Standard"  
}


module "vnet" {
    source              = "../modules/vnet_subnet"
    
    lb_internal_ipaddress = var.lb_internal_ipaddress
    location              = var.LOCATION
    prefix                = var.PREFIX
    resource_group_name   = azurerm_resource_group.resourcegroup.name
    subnets_cidr          = var.subnets_cidr
    vnet                  = var.vnet
}


module "internal_loadbalancer" {
    //count = var.lb_deployed ? 1 : 0
    source             = "../modules/internal_loadbalancer"

    fgt_number_deployed        = var.FGT_NUMBER_DEPLOYED
    fgtifcint_id               = module.fortigate.fgtifcint_id
    lb_internal_ipaddress      = var.lb_internal_ipaddress
    location                   = var.LOCATION
    prefix                     = var.PREFIX
    resource_group_name        = azurerm_resource_group.resourcegroup.name
    subnets_cidr               = var.subnets_cidr
    subnet_subnet1_id          = module.vnet.subnet_subnet1_id
    subnet_subnet2_id          = module.vnet.subnet_subnet2_id
    subnet_subnet3_id          = module.vnet.subnet_subnet3_id
    subnet_subnet4_id          = module.vnet.subnet_subnet4_id
    subnet_subnet5_id          = module.vnet.subnet_subnet5_id                
    vnet                       = var.vnet
}


module "public_loadbalancer" {
    //count = var.lb_deployed ? 1 : 0
    source             = "../modules/public_loadbalancer"

    fgt_number_deployed        = var.FGT_NUMBER_DEPLOYED
    fgtifcext_id               = module.fortigate.fgtifcext_id
    location                   = var.LOCATION
    prefix                     = var.PREFIX
    resource_group_name        = azurerm_resource_group.resourcegroup.name
    subnets_cidr               = var.subnets_cidr
    subnet_subnet1_id          = module.vnet.subnet_subnet1_id
    subnet_subnet2_id          = module.vnet.subnet_subnet2_id
    subnet_subnet3_id          = module.vnet.subnet_subnet3_id
    subnet_subnet4_id          = module.vnet.subnet_subnet4_id
    subnet_subnet5_id          = module.vnet.subnet_subnet5_id                
    vnet                       = var.vnet
}


module "fortigate" {
    source              = "../modules/fortigate"

    fgt_accelerated_networking = var.FGT_ACCELERATED_NETWORKING
    fgt_api_key                = var.FGT_API_KEY
    fgt_byol_license_files     = var.FGT_BYOL_LICENSE_FILES
    fgt_flexvm_license_tokens  = var.FGT_FLEXVM_LICENSE_TOKENS
    fgt_image_sku              = var.FGT_IMAGE_SKU
    fgt_ipaddress_offset       = var.fgt_ipaddress_offset    
    fgt_number_deployed        = var.FGT_NUMBER_DEPLOYED
    fgt_password               = var.FGT_PASSWORD
    fgt_ssh_public_key_file    = var.FGT_SSH_PUBLIC_KEY_FILE
    fgt_username               = var.FGT_USERNAME
    fgt_version                = var.FGT_VERSION    
    fgt_vmsize                 = var.fgt_vmsize
    lb_internal_ipaddress      = var.lb_internal_ipaddress
    public_ip_address_elb_ip   = module.public_loadbalancer.public_ip_address_elb_ip
    location                   = var.LOCATION
    my_public_ip               = local.my_public_ip
    prefix                     = var.PREFIX
    resource_group_name        = azurerm_resource_group.resourcegroup.name
    storage_account_endpoint   = azurerm_storage_account.storageaccount.primary_blob_endpoint    
    subnets_cidr               = var.subnets_cidr
    subnet_subnet1_id          = module.vnet.subnet_subnet1_id
    subnet_subnet2_id          = module.vnet.subnet_subnet2_id
    subnet_subnet3_id          = module.vnet.subnet_subnet3_id
    subnet_subnet4_id          = module.vnet.subnet_subnet4_id
    subnet_subnet5_id          = module.vnet.subnet_subnet5_id                
    vnet                       = var.vnet
    web_ipaddress_offset       = var.web_ipaddress_offset
    web_subnet_number          = var.web_subnet_number
}


module "webserver_workload" {
    source              = "../modules/webserver_workload"

    web_accelerated_networking = true
    web_image_sku              = "18.04-LTS"
    web_ipaddress_offset       = var.web_ipaddress_offset
    web_number_deployed        = 2
    web_password               = var.FGT_PASSWORD
    web_subnet_number          = var.web_subnet_number
    web_username               = var.FGT_USERNAME
    web_version                = "latest"   
    web_vmsize                 = "Standard_D8_v4"
    location                   = var.LOCATION
    prefix                     = var.PREFIX
    resource_group_name        = azurerm_resource_group.resourcegroup.name
    storage_account_endpoint   = azurerm_storage_account.storageaccount.primary_blob_endpoint    
    subnets_cidr               = var.subnets_cidr
    subnets_ids                = module.vnet.subnets_ids
    vnet                       = var.vnet
}


module "fortitester_subnet_4" {
    source              = "../modules/fortitester"

    fts_accelerated_networking = true
    fts_image_sku              = "fts-vm-byol"
    fts_ipaddress_offset       = var.fts_ipaddress_offset
    fts_number_interfaces      = 3
    fts_password               = var.FGT_PASSWORD
    fts_subnet_number          = 4
    fts_username               = var.FGT_USERNAME
    fts_version                = "latest"   
    fts_vmsize                 = "Standard_DS4_v2"
    location                   = var.LOCATION
    lb_deployed                = false
    lb_external_id             = module.public_loadbalancer.lb_external_id
    prefix                     = var.PREFIX
    resource_group_name        = azurerm_resource_group.resourcegroup.name
    storage_account_endpoint   = azurerm_storage_account.storageaccount.primary_blob_endpoint
    subnets_cidr               = var.subnets_cidr
    subnets_ids                = module.vnet.subnets_ids    
    vnet                       = var.vnet
}

module "fortitester_subnet_1" {
    source              = "../modules/fortitester"

    fts_accelerated_networking = true
    fts_image_sku              = "fts-vm-byol"
    fts_ipaddress_offset       = var.fts_ipaddress_offset
    fts_number_interfaces      = 3
    fts_password               = var.FGT_PASSWORD
    fts_subnet_number          = 1
    fts_username               = var.FGT_USERNAME
    fts_version                = "latest"   
    fts_vmsize                 = "Standard_DS4_v2"
    location                   = var.LOCATION
    lb_deployed                = false
    lb_external_id             = module.public_loadbalancer.lb_external_id    
    prefix                     = var.PREFIX
    resource_group_name        = azurerm_resource_group.resourcegroup.name
    storage_account_endpoint   = azurerm_storage_account.storageaccount.primary_blob_endpoint
    subnets_cidr               = var.subnets_cidr
    subnets_ids                = module.vnet.subnets_ids    
    vnet                       = var.vnet
}

module "iperf3client_subnet_4" {
    source              = "../modules/iperf3client"

    ipf_accelerated_networking = true
    ipf_image_sku              = "18.04-LTS"
    ipf_ipaddress_offset       = 30
    ipf_number_deployed        = 1
    ipf_password               = var.FGT_PASSWORD
    ipf_subnet_number          = 4
    ipf_username               = var.FGT_USERNAME
    ipf_version                = "latest"   
    ipf_vmsize                 = "Standard_D8_v4"
    location                   = var.LOCATION
    prefix                     = var.PREFIX
    resource_group_name        = azurerm_resource_group.resourcegroup.name
    storage_account_endpoint   = azurerm_storage_account.storageaccount.primary_blob_endpoint    
    subnets_cidr               = var.subnets_cidr
    subnets_ids                = module.vnet.subnets_ids
    vnet                       = var.vnet
}

module "iperf3client_subnet_1" {
    source              = "../modules/iperf3client"

    ipf_accelerated_networking = true
    ipf_image_sku              = "18.04-LTS"
    ipf_ipaddress_offset       = 30
    ipf_number_deployed        = 1
    ipf_password               = var.FGT_PASSWORD
    ipf_subnet_number          = 1
    ipf_username               = var.FGT_USERNAME
    ipf_version                = "latest"   
    ipf_vmsize                 = "Standard_D8_v4"
    location                   = var.LOCATION
    prefix                     = var.PREFIX
    resource_group_name        = azurerm_resource_group.resourcegroup.name
    storage_account_endpoint   = azurerm_storage_account.storageaccount.primary_blob_endpoint    
    subnets_cidr               = var.subnets_cidr
    subnets_ids                = module.vnet.subnets_ids
    vnet                       = var.vnet
}