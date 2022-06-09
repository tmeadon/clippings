provider "azurerm" {
  features {}
}

module "tags" {
  source = "../tags"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = module.tags.common_tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet.name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  address_space = [var.vnet.address_prefix]
}

resource "azurerm_subnet" "firewall_subnet" {
  count               = var.firewall != null ? 1 : 0
  name                = "AzureFirewallSubnet"
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name

  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.firewall.subnet_address_prefix]
}

resource "azurerm_subnet" "vpn_gateway_subnet" {
  count               = var.vpn_gateway != null ? 1 : 0
  name                = "GatewaySubnet"
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name

  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.vpn_gateway.subnet_address_prefix]
}