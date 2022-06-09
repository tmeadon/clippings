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

resource "azurerm_subnet" "name" {
  for_each            = { for s in var.vnet.subnets : s.name => s }
  name                = each.value.name
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name

  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.address_prefix]
}

resource "azurerm_virtual_network_peering" "peer_spoke_to_hub" {
  name                = "${var.vnet.name}_to_${var.hub.vnet_name}"
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name

  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = var.hub.vnet_id
  use_remote_gateways       = var.hub.has_gateway
}

resource "azurerm_virtual_network_peering" "peer_hub_to_spoke" {
  name                = "${var.hub.vnet_name}_to_${var.vnet.name}"
  resource_group_name = var.hub.vnet_resource_group_name

  virtual_network_name      = var.hub.vnet_name
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
  allow_gateway_transit     = var.hub.has_gateway
}