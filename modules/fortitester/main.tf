##############################################################################################################
#
# FortiTester
#
##############################################################################################################

resource "azurerm_network_security_group" "ftsnsg" {
  name                = "${var.prefix}-FTS-NSG-subnet-${var.fts_subnet_number}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "ftsnsgallowallout" {
  name                        = "AllowAllOutbound"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.ftsnsg.name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "ftsnsgallowallin" {
  name                        = "AllowAllInbound"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.ftsnsg.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_public_ip" "ftspublicip" {
  name                      = "${var.prefix}-FTS-subnet-${var.fts_subnet_number}-Public-IP"
  location                  = var.location
  resource_group_name       = var.resource_group_name
  allocation_method         = "Dynamic"
}

resource "azurerm_network_interface" "ftsifc" {
  count                         = var.fts_number_interfaces
  name                          = "${var.prefix}-FTS-subnet-${var.fts_subnet_number}-IFC-${count.index+1}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = false
  enable_accelerated_networking = var.fts_accelerated_networking

  ip_configuration {
    name                          = "interface${count.index+1}"
    subnet_id                     = var.subnets_ids[var.fts_subnet_number]
    private_ip_address_allocation = "static"
    private_ip_address            = cidrhost(var.subnets_cidr[var.fts_subnet_number],var.fts_ipaddress_offset+count.index)
    public_ip_address_id          = (var.fts_public_ip == true && count.index == 0) ? azurerm_public_ip.ftspublicip.id : null
  }
}


resource "azurerm_network_interface_security_group_association" "ftsifcnsg" {
  count                     = var.fts_number_interfaces
  network_interface_id      = azurerm_network_interface.ftsifc[count.index].id
  network_security_group_id = azurerm_network_security_group.ftsnsg.id
}



resource "azurerm_virtual_machine" "ftsvm" {
  name                         = "${var.prefix}-FTS-VM-subnet-${var.fts_subnet_number}"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  network_interface_ids        = concat(azurerm_network_interface.ftsifc[*].id)
  #Management Interface is Interface 0
  primary_network_interface_id = azurerm_network_interface.ftsifc[0].id
  vm_size                      = var.fts_vmsize

  identity {
    type = "SystemAssigned"
  }

/*
  // Marketplace
  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet-fortitester"
    sku       = var.fts_image_sku # "fts-vm-byol"
    version   = var.fts_version
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet-fortitester"
    name      = var.fts_image_sku # "fts-vm-byol"
  }

*/
  // Manual uplaod of v7.0.0 image
  storage_image_reference {
    id = "/subscriptions/fda770f9-b125-4474-abec-65a1cc1df596/resourceGroups/MG_Blob/providers/Microsoft.Compute/images/ftsv700b0008"
  }





  storage_os_disk {
    name              = "${var.prefix}-FTS-subnet-${var.fts_subnet_number}-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = "${var.prefix}-FTS-subnet-${var.fts_subnet_number}-DATADISK"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "1024"
  }

  os_profile {
    computer_name  = "${var.prefix}-FTS-${var.fts_subnet_number}"
    admin_username = var.fts_username
    admin_password = var.fts_password
    #custom_data    = data.template_file.fts_custom_data[count.index].rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
  
  boot_diagnostics {
    enabled     = true
    storage_uri = var.storage_account_endpoint
  }
}


resource "azurerm_lb_nat_rule" "ftsmgmthttps" {
  count = var.lb_deployed ? 1 : 0
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = var.lb_external_id 
  name                           = "${var.prefix}-FTS-subnet-${var.fts_subnet_number}-HTTPS"
  protocol                       = "Tcp"
  frontend_port                  = 40100+var.fts_subnet_number
  backend_port                   = 443
  frontend_ip_configuration_name = "${var.prefix}-MGMT-PIP"
}

resource "azurerm_lb_nat_rule" "ftsmgmtssh" {
  count = var.lb_deployed ? 1 : 0
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = var.lb_external_id 
  name                           = "${var.prefix}-FTS-subnet-${var.fts_subnet_number}-SSH"
  protocol                       = "Tcp"
  frontend_port                  = 50100+var.fts_subnet_number
  backend_port                   = 22
  frontend_ip_configuration_name = "${var.prefix}-MGMT-PIP"
}

resource "azurerm_network_interface_nat_rule_association" "ftsmgmthttpsvm" {
  count = var.lb_deployed ? 1 : 0
  network_interface_id  = azurerm_network_interface.ftsifc[0].id
  ip_configuration_name = "interface1"
  nat_rule_id           = azurerm_lb_nat_rule.ftsmgmthttps[0].id
}

resource "azurerm_network_interface_nat_rule_association" "ftsmgmtsshvm" {
  count = var.lb_deployed ? 1 : 0
  network_interface_id  = azurerm_network_interface.ftsifc[0].id
  ip_configuration_name = "interface1"
  nat_rule_id           = azurerm_lb_nat_rule.ftsmgmtssh[0].id
}



/*
data "template_file" "fts_custom_data" {
  template = file("${path.module}/customdata.sh")

  vars = {
    fts_vm_name         = "{var.prefix}-FTS-VM-subnet-${var.fts_subnet_number}"
    fts_username        = var.fts_username
    fts_external_ipaddr = cidrhost(var.subnets_cidr["1"],var.fts_ipaddress_offset+count.index)
    fts_external_mask   = element(split("/", var.subnets_cidr["1"]),1)
    fts_external_gw     = cidrhost(var.subnets_cidr["1"],1)    
    fts_internal_ipaddr = cidrhost(var.subnets_cidr["2"],var.fts_ipaddress_offset+count.index)
    fts_internal_mask   = element(split("/", var.subnets_cidr["2"]),1)
    fts_internal_gw     = cidrhost(var.subnets_cidr["2"],1)    
    fts_protected_net   = var.subnets_cidr["4"]
    vnet_network        = var.vnet
  }
}
*/


