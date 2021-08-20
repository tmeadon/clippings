output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vm_subnet_id" {
  value = azurerm_subnet.vnet_vm_subnet.id
}

output "vm_subnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "pip_ids" {
  value = azurerm_public_ip.pips.*.id
}