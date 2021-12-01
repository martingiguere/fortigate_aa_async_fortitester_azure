##############################################################################################################
#
# Ubuntu based Web WorkLoad
#
##############################################################################################################

resource "azurerm_network_security_group" "webnsg" {
  name                = "${var.prefix}-WEB-NSG-subnet-${var.web_subnet_number}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "webnsgallowallout" {
  name                        = "AllowAllOutbound"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.webnsg.name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "webnsgallowallin" {
  name                        = "AllowAllInbound"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.webnsg.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}



resource "azurerm_network_interface" "webifc" {
  count                         = var.web_number_deployed
  name                          = "${var.prefix}-WEB-${count.index+1}-IFC-subnet-${var.web_subnet_number}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = false
  enable_accelerated_networking = var.web_accelerated_networking

  ip_configuration {
    name                          = "interface1"
    subnet_id                     = var.subnets_ids[var.web_subnet_number]
    private_ip_address_allocation = "static"
    private_ip_address            = cidrhost(var.subnets_cidr[var.web_subnet_number],var.web_ipaddress_offset+count.index)  
  }
}

resource "azurerm_network_interface_security_group_association" "webifcnsg" {
  count                     = var.web_number_deployed
  network_interface_id      = azurerm_network_interface.webifc[count.index].id
  network_security_group_id = azurerm_network_security_group.webnsg.id
}



resource "azurerm_virtual_machine" "webvm" {
  count                        = var.web_number_deployed
  name                         = "${var.prefix}-WEB-${count.index+1}-VM-subnet-${var.web_subnet_number}"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  network_interface_ids        = [azurerm_network_interface.webifc[count.index].id]
  primary_network_interface_id = azurerm_network_interface.webifc[count.index].id
  vm_size                      = var.web_vmsize

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = var.web_image_sku
    version   = var.web_version
  }

  storage_os_disk {
    name              = "${var.prefix}-WEB-${count.index+1}-subnet-${var.web_subnet_number}-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}-WEB-${count.index+1}-subnet-${var.web_subnet_number}"
    admin_username = var.web_username
    admin_password = var.web_password
    custom_data    = data.template_file.web_custom_data[count.index].rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = var.storage_account_endpoint
  }

}

data "template_file" "web_custom_data" {
  count    = var.web_number_deployed
  template = file("${path.module}/customdata.sh")

  vars = {
    web_vm_name         = "${var.prefix}-WEB-${count.index+1}-subnet-${var.web_subnet_number}"
  }
}
