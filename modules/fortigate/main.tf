##############################################################################################################
#
# FortiGate Active/Active Load Balanced pair of standalone FortiGate VMs for resilience and scale
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################


resource "azurerm_availability_set" "fgtavset" {
  name                = "${var.prefix}-FGT-AVSET"
  location            = var.location
  managed             = true
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_group" "fgtnsg" {
  name                = "${var.prefix}-FGT-NSG"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "fgtnsgallowallout" {
  name                        = "AllowAllOutbound"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.fgtnsg.name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "fgtnsgallowallin" {
  name                        = "AllowAllInbound"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.fgtnsg.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}



### Per FortiGate loop


resource "azurerm_network_interface" "fgtifcext" {
  count                         = var.fgt_number_deployed
  name                          = "${var.prefix}-FGT-${count.index+1}-IFC-EXT"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.fgt_accelerated_networking

  ip_configuration {
    name                          = "interface1"
    subnet_id                     = var.subnet_subnet1_id
    private_ip_address_allocation = "static"
    private_ip_address            = cidrhost(var.subnets_cidr["1"],var.fgt_ipaddress_offset+count.index)
  }
}

resource "azurerm_network_interface_security_group_association" "fgtifcextnsg" {
  count                     = var.fgt_number_deployed
  network_interface_id      = azurerm_network_interface.fgtifcext[count.index].id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}


resource "azurerm_network_interface" "fgtifcint" {
  count                = var.fgt_number_deployed
  name                 = "${var.prefix}-FGT-${count.index+1}-IFC-INT"
  location             = var.location
  resource_group_name  = var.resource_group_name
  enable_ip_forwarding = true
  enable_accelerated_networking = var.fgt_accelerated_networking  

  ip_configuration {
    name                          = "interface2"
    subnet_id                     = var.subnet_subnet2_id
    private_ip_address_allocation = "static"
    private_ip_address            = cidrhost(var.subnets_cidr["2"],var.fgt_ipaddress_offset+count.index)
  }
}

resource "azurerm_network_interface_security_group_association" "fgtifcintnsg" {
  count                     = var.fgt_number_deployed
  network_interface_id      = azurerm_network_interface.fgtifcint[count.index].id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}


resource "azurerm_network_interface" "fgtifcmid" {
  count                = var.fgt_number_deployed
  name                 = "${var.prefix}-FGT-${count.index+1}-IFC-MID"
  location             = var.location
  resource_group_name  = var.resource_group_name
  enable_ip_forwarding = true
  enable_accelerated_networking = var.fgt_accelerated_networking  

  ip_configuration {
    name                          = "interface3"
    subnet_id                     = var.subnet_subnet3_id
    private_ip_address_allocation = "static"
    private_ip_address            = cidrhost(var.subnets_cidr["3"],var.fgt_ipaddress_offset+count.index)
  }
}

resource "azurerm_network_interface_security_group_association" "fgtifcmidnsg" {
  count                     = var.fgt_number_deployed
  network_interface_id      = azurerm_network_interface.fgtifcmid[count.index].id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}



resource "azurerm_virtual_machine" "fgtvm" {
  count                        = var.fgt_number_deployed
  name                         = "${var.prefix}-FGT-${count.index+1}-VM"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  network_interface_ids        = [azurerm_network_interface.fgtifcext[count.index].id, azurerm_network_interface.fgtifcint[count.index].id, azurerm_network_interface.fgtifcmid[count.index].id]
  primary_network_interface_id = azurerm_network_interface.fgtifcext[count.index].id
  vm_size                      = var.fgt_vmsize
  availability_set_id          = azurerm_availability_set.fgtavset.id

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = var.fgt_image_sku
    version   = var.fgt_version
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
    name      = var.fgt_image_sku
  }

  storage_os_disk {
    name              = "${var.prefix}-FGT-${count.index+1}-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}-FGT-${count.index+1}"
    admin_username = var.fgt_username
    admin_password = var.fgt_password
    custom_data    = data.template_file.fgt_custom_data[count.index].rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = var.storage_account_endpoint
  }


}

data "template_file" "fgt_custom_data" {
  count    = var.fgt_number_deployed
  template = file("${path.module}/customdata.tpl")

  vars = {
    fgt_vm_name              = "${var.prefix}-FGT-${count.index+1}"
    fgt_license_file         = var.fgt_byol_license_files[count.index+1]
    fgt_license_flexvm       = var.fgt_flexvm_license_tokens[count.index+1]
    fgt_username             = var.fgt_username
    fgt_ssh_public_key       = var.fgt_ssh_public_key_file
    fgt_external_ipaddr      = cidrhost(var.subnets_cidr["1"],var.fgt_ipaddress_offset+count.index)
    fgt_external_mask        = element(split("/", var.subnets_cidr["1"]),1)
    fgt_external_gw          = cidrhost(var.subnets_cidr["1"],1)    
    fgt_internal_ipaddr      = cidrhost(var.subnets_cidr["2"],var.fgt_ipaddress_offset+count.index)
    fgt_internal_mask        = element(split("/", var.subnets_cidr["2"]),1)
    fgt_internal_gw          = cidrhost(var.subnets_cidr["2"],1)    
    fgt_middle_ipaddr        = cidrhost(var.subnets_cidr["3"],var.fgt_ipaddress_offset+count.index)
    fgt_middle_mask          = element(split("/", var.subnets_cidr["3"]),1)
    fgt_middle_gw            = cidrhost(var.subnets_cidr["3"],1) 
    fgt_ha_peerip1           = cidrhost(var.subnets_cidr["3"],(((count.index+1) % var.fgt_number_deployed ))+var.fgt_ipaddress_offset)
    fgt_ha_peerip2           = var.fgt_number_deployed >= 3 ? cidrhost(var.subnets_cidr["3"],(((count.index+2) % var.fgt_number_deployed ))+var.fgt_ipaddress_offset) : ""
    fgt_ha_peerip3           = var.fgt_number_deployed >= 4 ? cidrhost(var.subnets_cidr["3"],(((count.index+3) % var.fgt_number_deployed ))+var.fgt_ipaddress_offset) : ""
    fgt_api_key              = var.fgt_api_key    
    fgt_protected_net        = var.subnets_cidr["4"]
    my_public_ip             = var.my_public_ip
    prefix                   = var.prefix
    public_ip_address_elb_ip = var.public_ip_address_elb_ip
    vnet_network             = var.vnet
    web_subnet_number        = var.web_subnet_number
    web_instance_ip          = cidrhost(var.subnets_cidr[var.web_subnet_number],var.web_ipaddress_offset)
  }
}
