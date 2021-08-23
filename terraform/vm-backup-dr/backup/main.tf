resource "azurerm_recovery_services_vault" "backup" {
  resource_group_name = var.resource_group_name
  name                = var.vault_name
  location            = var.location
  sku                 = "Standard"
}

resource "azurerm_backup_policy_vm" "policy1" {
  resource_group_name = var.resource_group_name
  name                = "policy1"
  recovery_vault_name = azurerm_recovery_services_vault.backup.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 7
  }
}

resource "azurerm_backup_protected_vm" "vm" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.backup.name
  source_vm_id        = var.vm_id
  backup_policy_id    = azurerm_backup_policy_vm.policy1.id
}