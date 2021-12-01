terraform {
    required_version = ">= 0.14"
}

##############################################################################################################
#
# Deployment of the virtual network
#
##############################################################################################################

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-VNET"
  address_space       = [var.vnet]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnet1" {
  name                 = "${var.prefix}-SUBNET-FGT-EXTERNAL"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnets_cidr["1"]]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "${var.prefix}-SUBNET-FGT-INTERNAL"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnets_cidr["2"]]
}

resource "azurerm_subnet" "subnet3" {
  name                 = "${var.prefix}-SUBNET-FGT-MID"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnets_cidr["3"]]
}

resource "azurerm_subnet" "subnet4" {
  name                 = "${var.prefix}-SUBNET-PROTECTED-A"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnets_cidr["4"]]
}

resource "azurerm_subnet" "subnet5" {
  name                 = "${var.prefix}-SUBNET-PROTECTED-B"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnets_cidr["5"]]
}


resource "azurerm_subnet_route_table_association" "subnet4rt" {
  subnet_id      = azurerm_subnet.subnet4.id
  route_table_id = azurerm_route_table.protectedaroute.id

  lifecycle {
    ignore_changes = [route_table_id]
  }
}


resource "azurerm_route_table" "protectedaroute" {
  name                = "${var.prefix}-RT-PROTECTED-A"
  location            = var.location
  resource_group_name = var.resource_group_name

  route {
    name                   = "VirtualNetwork"
    address_prefix         = var.vnet
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.lb_internal_ipaddress
  }
  route {
    name           = "Subnet"
    address_prefix = var.subnets_cidr["4"]
    next_hop_type  = "VnetLocal"
  }
  route {
    name                   = "Default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "subnet5rt" {
  subnet_id      = azurerm_subnet.subnet5.id
  route_table_id = azurerm_route_table.protectedbroute.id

  lifecycle {
    ignore_changes = [route_table_id]
  }
}

resource "azurerm_route_table" "protectedbroute" {
  name                = "${var.prefix}-RT-PROTECTED-B"
  location            = var.location
  resource_group_name = var.resource_group_name

  route {
    name                   = "VirtualNetwork"
    address_prefix         = var.vnet
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.lb_internal_ipaddress
  }
  route {
    name           = "Subnet"
    address_prefix = var.subnets_cidr["5"]
    next_hop_type  = "VnetLocal"
  }
  route {
    name                   = "Default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.lb_internal_ipaddress
  }
}

