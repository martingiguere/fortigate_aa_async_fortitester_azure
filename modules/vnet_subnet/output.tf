output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "subnets_ids" {
  value = tomap({
    "1" = azurerm_subnet.subnet1.id,
    "2" = azurerm_subnet.subnet2.id,
    "3" = azurerm_subnet.subnet3.id,
    "4" = azurerm_subnet.subnet4.id,
    "5" = azurerm_subnet.subnet5.id
    }
  )
}

output "subnet_subnet1_id" {
  value = azurerm_subnet.subnet1.id
}

output "subnet_subnet1_name" {
  value = azurerm_subnet.subnet1.name
}

output "subnet_subnet2_id" {
  value = azurerm_subnet.subnet2.id
}

output "subnet_subnet2_name" {
  value = azurerm_subnet.subnet2.name
}

output "subnet_subnet3_id" {
  value = azurerm_subnet.subnet3.id
}

output "subnet_subnet3_name" {
  value = azurerm_subnet.subnet3.name
}

output "subnet_subnet4_id" {
  value = azurerm_subnet.subnet4.id
}

output "subnet_subnet4_name" {
  value = azurerm_subnet.subnet4.name
}

output "subnet_subnet5_id" {
  value = azurerm_subnet.subnet5.id
}

output "subnet_subnet5_name" {
  value = azurerm_subnet.subnet5.name
}

