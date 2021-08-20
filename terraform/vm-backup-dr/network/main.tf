resource "azurerm_virtual_network" "vnet" {
  resource_group_name = var.resource_group_name
  name                = var.name
  location            = var.location
  address_space       = [var.cidr]
}

resource "azurerm_subnet" "vnet_vm_subnet" {
  name                 = "vm_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.cidr, 4, 0)]
}

resource "azurerm_public_ip" "pips" {
  count               = var.pip_count
  resource_group_name = var.resource_group_name
  name                = "pip-${count.index}"
  location            = var.location
  allocation_method   = "Dynamic"
}