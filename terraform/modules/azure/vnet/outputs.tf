output "vnet-id" {
  description = "id for the new vnet"
  value       = azurerm_virtual_network.vnet.id
}

output "subnets" {
  description = "ids of the new subnets"
  value       = zipmap(azurerm_subnet.subnet.*.name, azurerm_subnet.subnet.*.id)
}
