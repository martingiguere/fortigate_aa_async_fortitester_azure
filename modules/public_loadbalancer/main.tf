##############################################################################################################
#
# External Load Balancers Deployment
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################



resource "azurerm_public_ip" "elbpip" {
  name                = "${var.prefix}-ELB-PIP"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = format("%s-%s", lower(var.prefix), "lb-pip")
}

resource "azurerm_public_ip" "mgmtpip" {
  name                = "${var.prefix}-MGMT-PIP"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = format("%s-%s", lower(var.prefix), "mgmt-pip")
}

resource "azurerm_lb" "elb" {
  name                = "${var.prefix}-ExternalLoadBalancer"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.prefix}-ELB-PIP"
    public_ip_address_id = azurerm_public_ip.elbpip.id
  }

  frontend_ip_configuration {
    name                 = "${var.prefix}-MGMT-PIP"
    public_ip_address_id = azurerm_public_ip.mgmtpip.id
  }
}


data "azurerm_public_ip" "elbpip" {
  name                = azurerm_public_ip.elbpip.name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_lb.elb]
}

data "azurerm_public_ip" "mgmtpip" {
  name                = azurerm_public_ip.mgmtpip.name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_lb.elb]
}

output "elb_public_ip_address" {
  value = data.azurerm_public_ip.elbpip.ip_address
}

resource "azurerm_lb_backend_address_pool" "elbbackend" {
  loadbalancer_id = azurerm_lb.elb.id
  name            = "BackEndPool"
}

resource "azurerm_lb_probe" "elbprobe" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.elb.id
  name                = "lbprobe"
  port                = 8008
}

resource "azurerm_lb_rule" "lbruleiperf" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.elb.id
  name                           = "PublicLBRule-FE1-iperf"
  protocol                       = "Tcp"
  frontend_port                  = 5201
  backend_port                   = 5201
  frontend_ip_configuration_name = "${var.prefix}-ELB-PIP"
  probe_id                       = azurerm_lb_probe.elbprobe.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.elbbackend.id
  enable_floating_ip             = true
}

/*
resource "azurerm_lb_rule" "lbrulehttp" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.elb.id
  name                           = "PublicLBRule-FE1-http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.prefix}-ELB-PIP"
  probe_id                       = azurerm_lb_probe.elbprobe.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.elbbackend.id
  enable_floating_ip             = true
}
*/

/*
resource "azurerm_lb_rule" "lbrulehttps" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.elb.id
  name                           = "PublicLBRule-FE1-https"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "${var.prefix}-ELB-PIP"
  probe_id                       = azurerm_lb_probe.elbprobe.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.elbbackend.id
  enable_floating_ip             = true
}
*/


resource "azurerm_lb_rule" "lbruleudp" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.elb.id
  name                           = "PublicLBRule-FE1-udp10551"
  protocol                       = "Udp"
  frontend_port                  = 10551
  backend_port                   = 10551
  frontend_ip_configuration_name = "${var.prefix}-ELB-PIP"
  probe_id                       = azurerm_lb_probe.elbprobe.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.elbbackend.id
  enable_floating_ip             = true
}


resource "azurerm_lb_nat_rule" "fgtmgmthttps" {
  count                          = var.fgt_number_deployed
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.elb.id
  name                           = "${var.prefix}-FGT-${count.index+1}-HTTPS"
  protocol                       = "Tcp"
  frontend_port                  = 40030+count.index
  backend_port                   = 443
  frontend_ip_configuration_name = "${var.prefix}-MGMT-PIP"
}

resource "azurerm_lb_nat_rule" "fgtmgmtssh" {
  count                          = var.fgt_number_deployed  
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.elb.id
  name                           = "${var.prefix}-FGT-${count.index+1}-SSH"
  protocol                       = "Tcp"
  frontend_port                  = 50030+count.index
  backend_port                   = 22
  frontend_ip_configuration_name = "${var.prefix}-MGMT-PIP"
}


resource "azurerm_network_interface_backend_address_pool_association" "fgtifcext2elbbackendpool" {
  count                   = var.fgt_number_deployed  
  network_interface_id    = var.fgtifcext_id[count.index]
  ip_configuration_name   = "interface1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elbbackend.id
}


resource "azurerm_network_interface_nat_rule_association" "fgtmgmthttpsvm" {
  count                 = var.fgt_number_deployed
  network_interface_id  = var.fgtifcext_id[count.index]
  ip_configuration_name = "interface1"
  nat_rule_id           = azurerm_lb_nat_rule.fgtmgmthttps[count.index].id
}

resource "azurerm_network_interface_nat_rule_association" "fgtmgmtsshvm" {
  count                 = var.fgt_number_deployed  
  network_interface_id  = var.fgtifcext_id[count.index]
  ip_configuration_name = "interface1"
  nat_rule_id           = azurerm_lb_nat_rule.fgtmgmtssh[count.index].id
}


