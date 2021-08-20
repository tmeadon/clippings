output "vm_id" {
  value = azurerm_windows_virtual_machine.vm.id
}

data "azurerm_managed_disk" "os_disk" {
  name                = azurerm_windows_virtual_machine.vm.os_disk[0].name
  resource_group_name = var.resource_group_name
}

output "os_disk" {
  value = {
    id  = data.azurerm_managed_disk.os_disk.id
    sku = data.azurerm_managed_disk.os_disk.storage_account_type
  }
}

output "data_disk" {
  value = {
    id  = azurerm_managed_disk.vm_data_disk.id
    sku = azurerm_managed_disk.vm_data_disk.storage_account_type
  }
}

output "nic_id" {
  value = azurerm_network_interface.vm_nic.id
}