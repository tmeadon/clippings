output "windowsVms" {
  description = "A list of Windows VMs and their IDs"
  value       = zipmap(azurerm_virtual_machine.windows.*.name, azurerm_virtual_machine.windows.*.id)
}