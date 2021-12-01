##############################################################################################################
#
# Ubuntu based Web WorkLoad
#
##############################################################################################################

resource "azurerm_network_security_group" "ipfnsg" {
  name                = "${var.prefix}-IPF-NSG-subnet-${var.ipf_subnet_number}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "ipfnsgallowallout" {
  name                        = "AllowAllOutbound"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.ipfnsg.name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "ipfnsgallowallin" {
  name                        = "AllowAllInbound"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.ipfnsg.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_public_ip" "ipfpublicip" {
  name                      = "${var.prefix}-IPF-subnet-${var.ipf_subnet_number}-Public-IP"
  location                  = var.location
  resource_group_name       = var.resource_group_name
  allocation_method         = "Dynamic"
}


resource "azurerm_network_interface" "ipfifc" {
  count                         = var.ipf_number_deployed
  name                          = "${var.prefix}-IPF-${count.index+1}-IFC-subnet-${var.ipf_subnet_number}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = false
  enable_accelerated_networking = var.ipf_accelerated_networking

  ip_configuration {
    name                          = "interface1"
    subnet_id                     = var.subnets_ids[var.ipf_subnet_number]
    private_ip_address_allocation = "static"
    private_ip_address            = cidrhost(var.subnets_cidr[var.ipf_subnet_number],var.ipf_ipaddress_offset+count.index)
    public_ip_address_id          = (var.ipf_public_ip == true && count.index == 0) ? azurerm_public_ip.ipfpublicip.id : null 
  }
}

resource "azurerm_network_interface_security_group_association" "ipfifcnsg" {
  count                     = var.ipf_number_deployed
  network_interface_id      = azurerm_network_interface.ipfifc[count.index].id
  network_security_group_id = azurerm_network_security_group.ipfnsg.id
}



resource "azurerm_virtual_machine" "ipfvm" {
  count                        = var.ipf_number_deployed
  name                         = "${var.prefix}-IPF-${count.index+1}-VM-subnet-${var.ipf_subnet_number}"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  network_interface_ids        = [azurerm_network_interface.ipfifc[count.index].id]
  primary_network_interface_id = azurerm_network_interface.ipfifc[count.index].id
  vm_size                      = var.ipf_vmsize

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = var.ipf_image_sku
    version   = var.ipf_version
  }

  storage_os_disk {
    name              = "${var.prefix}-IPF-${count.index+1}-subnet-${var.ipf_subnet_number}-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}-IPF-${count.index+1}-subnet-${var.ipf_subnet_number}"
    admin_username = var.ipf_username
    admin_password = var.ipf_password
    custom_data    = data.template_file.ipf_custom_data[count.index].rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = var.storage_account_endpoint
  }

}

data "template_file" "ipf_custom_data" {
  count    = var.ipf_number_deployed
  template = file("${path.module}/customdata.sh")

  vars = {
    ipf_vm_name         = "${var.prefix}-IPF-${count.index+1}-subnet-${var.ipf_subnet_number}"
  }
}
