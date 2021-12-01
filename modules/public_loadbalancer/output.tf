output "lb_external_id" {
  value = azurerm_lb.elb.id
}

output "public_ip_address_elb_id" {
  value = azurerm_public_ip.elbpip.id
}

output "public_ip_address_elb_ip" {
  value = data.azurerm_public_ip.elbpip.ip_address
}

output "public_ip_address_mgmt_id" {
  value = azurerm_public_ip.mgmtpip.id
}

output "public_ip_address_mgmt_ip" {
  value = data.azurerm_public_ip.mgmtpip.ip_address
}

/*
  frontend_ip_configuration {
    name                 = "${var.prefix}-ELB-PIP"

  frontend_ip_configuration {
    name                 = "${var.prefix}-MGMT-PIP"    



*/