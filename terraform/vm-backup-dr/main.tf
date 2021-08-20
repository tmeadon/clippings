resource "azurerm_resource_group" "rg" {
  name     = var.baseName
  location = var.primaryLocation

  tags = {
    # "DestroyTime" = "18:00"
  }
}

resource "azurerm_resource_group" "rg_secondary" {
  name     = "${var.baseName}-dr"
  location = var.secondaryLocation

  tags = {
    # "DestroyTime" = "18:00"
  }
}

module "primary_networking" {
  source              = "./network"
  resource_group_name = azurerm_resource_group.rg.name
  name                = var.baseName
  location            = var.primaryLocation
  pip_count           = 1
  cidr                = "10.0.0.0/16"
}

module "secondary_networking" {
  source              = "./network"
  resource_group_name = azurerm_resource_group.rg_secondary.name
  name                = "${var.baseName}-dr"
  location            = var.secondaryLocation
  pip_count           = 1
  cidr                = "10.1.0.0/16"
}

module "vm1" {
  source              = "./vm"
  resource_group_name = azurerm_resource_group.rg.name
  vm_details = {
    name           = "vm1"
    location       = var.primaryLocation
    subnet_id      = module.primary_networking.vm_subnet_id
    pip_id         = module.primary_networking.pip_ids[0]
    dsc_url        = var.dscUrl
    dsc_sas_token  = var.dscUrlSasToken
    admin_password = var.adminPassword
  }
}

module "vm1-dr" {
  source = "./dr"
  resource_groups = {
    primary   = azurerm_resource_group.rg.name
    secondary = azurerm_resource_group.rg_secondary.name
  }
  locations = {
    primary   = var.primaryLocation
    secondary = var.secondaryLocation
  }
  vault_name               = var.baseName
  vm_id                    = module.vm1.vm_id
  nic_id                   = module.vm1.nic_id
  os_disk                  = module.vm1.os_disk
  data_disk                = module.vm1.data_disk
  target_network_id        = module.secondary_networking.vnet_id
  target_subnet_name       = module.secondary_networking.vm_subnet_name
  target_pip_id            = module.secondary_networking.pip_ids[0]
  target_resource_group_id = azurerm_resource_group.rg_secondary.id
}