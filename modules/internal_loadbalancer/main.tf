##############################################################################################################
#
# Internal Load Balancers Deployment
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################




resource "azurerm_lb" "ilb" {
  name                = "${var.prefix}-InternalLoadBalancer"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "${var.prefix}-ILB-PIP"
    subnet_id                     = var.subnet_subnet2_id
    private_ip_address            = var.lb_internal_ipaddress
    private_ip_address_allocation = "Static"
  }
}

resource "azurerm_lb_probe" "ilbprobe" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.ilb.id
  name                = "lbprobe"
  port                = 8008
}

resource "azurerm_lb_rule" "lb_haports_rule" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.ilb.id
  name                           = "lb_haports_rule"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  load_distribution              = "SourceIPProtocol"
  frontend_ip_configuration_name = "${var.prefix}-ILB-PIP"
  probe_id                       = azurerm_lb_probe.ilbprobe.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.ilbbackend.id
}

resource "azurerm_lb_backend_address_pool" "ilbbackend" {
  loadbalancer_id = azurerm_lb.ilb.id
  name            = "BackEndPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "fgtifcint2ilbbackendpool" {
  count                   = var.fgt_number_deployed  
  network_interface_id    = var.fgtifcint_id[count.index]
  ip_configuration_name   = "interface2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ilbbackend.id
}




