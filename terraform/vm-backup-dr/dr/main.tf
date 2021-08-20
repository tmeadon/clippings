resource "azurerm_recovery_services_vault" "rsv" {
  resource_group_name = var.resource_groups.secondary
  name                = var.vault_name
  location            = var.locations.secondary
  sku                 = "Standard"
}

resource "azurerm_site_recovery_fabric" "primary_recovery_fabric" {
  resource_group_name = var.resource_groups.secondary
  name                = "primary-fabric"
  location            = var.locations.primary
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name
}

resource "azurerm_site_recovery_fabric" "secondary_recovery_fabric" {
  resource_group_name = var.resource_groups.secondary
  name                = "secondary-fabric"
  location            = var.locations.secondary
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name
}

resource "azurerm_site_recovery_protection_container" "primary_protection_container" {
  resource_group_name  = var.resource_groups.secondary
  name                 = "primary-protection-container"
  recovery_vault_name  = azurerm_recovery_services_vault.rsv.name
  recovery_fabric_name = azurerm_site_recovery_fabric.primary_recovery_fabric.name
}

resource "azurerm_site_recovery_protection_container" "secondary_protection_container" {
  resource_group_name  = var.resource_groups.secondary
  name                 = "secondary-protection-container"
  recovery_vault_name  = azurerm_recovery_services_vault.rsv.name
  recovery_fabric_name = azurerm_site_recovery_fabric.secondary_recovery_fabric.name
}

resource "azurerm_site_recovery_replication_policy" "replication_policy" {
  resource_group_name                                  = var.resource_groups.secondary
  name                                                 = "default-replication"
  recovery_vault_name                                  = azurerm_recovery_services_vault.rsv.name
  recovery_point_retention_in_minutes                  = 24 * 60
  application_consistent_snapshot_frequency_in_minutes = 4 * 60
}

resource "azurerm_site_recovery_protection_container_mapping" "container_mapping" {
  resource_group_name                       = var.resource_groups.secondary
  name                                      = "mapping"
  recovery_vault_name                       = azurerm_recovery_services_vault.rsv.name
  recovery_fabric_name                      = azurerm_site_recovery_fabric.primary_recovery_fabric.name
  recovery_source_protection_container_name = azurerm_site_recovery_protection_container.primary_protection_container.name
  recovery_target_protection_container_id   = azurerm_site_recovery_protection_container.secondary_protection_container.id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.replication_policy.id
}

resource "random_string" "random" {
  length  = 10
  special = false
}

resource "azurerm_storage_account" "primary_cache" {
  resource_group_name      = var.resource_groups.primary
  name                     = "${lower(random_string.random.result)}"
  location                 = var.locations.primary
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_site_recovery_replicated_vm" "vm_replication" {
  resource_group_name                       = var.resource_groups.secondary
  name                                      = "${local.vm_name}-repl"
  recovery_vault_name                       = azurerm_recovery_services_vault.rsv.name
  source_recovery_fabric_name               = azurerm_site_recovery_fabric.primary_recovery_fabric.name
  source_vm_id                              = var.vm_id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.replication_policy.id
  source_recovery_protection_container_name = azurerm_site_recovery_protection_container.primary_protection_container.name
  target_resource_group_id                  = var.target_resource_group_id
  target_recovery_fabric_id                 = azurerm_site_recovery_fabric.secondary_recovery_fabric.id
  target_recovery_protection_container_id   = azurerm_site_recovery_protection_container.secondary_protection_container.id
  target_network_id                         = var.target_network_id

  managed_disk {
    disk_id                    = var.os_disk.id
    staging_storage_account_id = azurerm_storage_account.primary_cache.id
    target_resource_group_id   = var.target_resource_group_id
    target_disk_type           = var.os_disk.sku
    target_replica_disk_type   = var.os_disk.sku
  }

  managed_disk {
    disk_id                    = var.data_disk.id
    staging_storage_account_id = azurerm_storage_account.primary_cache.id
    target_resource_group_id   = var.target_resource_group_id
    target_disk_type           = var.data_disk.sku
    target_replica_disk_type   = var.data_disk.sku
  }

  network_interface {
    source_network_interface_id   = var.nic_id
    target_subnet_name            = var.target_subnet_name
    recovery_public_ip_address_id = var.target_pip_id
  }
}