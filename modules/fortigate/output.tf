/*
output "fgtifcint_id" {
  value = join("", azurerm_network_interface.fgtifcint[*].id)
}
*/


output "fgtifcint_id" {
  value = azurerm_network_interface.fgtifcint[*].id
}

output "fgtifcext_id" {
  value = azurerm_network_interface.fgtifcext[*].id
}
