resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet-name
  address_space       = var.vnet-address-space
  location            = var.location
  resource_group_name = var.resource-group
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnets[count.index].subnet-name
  address_prefixes     = [var.subnets[count.index].subnet-address-prefix]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource-group
  count                = length(var.subnets)
}

