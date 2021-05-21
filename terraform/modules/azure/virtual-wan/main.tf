resource "azurerm_virtual_wan" "virtualWan" {
  name                       = var.vwanName
  resource_group_name        = var.resourceGroup
  location                   = var.vwanLocation
  allow_vnet_to_vnet_traffic = var.allowVnetToVnetTraffic
}

resource "azurerm_virtual_hub" "virtualHub" {
  count = length(keys(var.hubs))

  name                = var.hubs[keys(var.hubs)[count.index]].name
  resource_group_name = var.resourceGroup
  location            = var.hubs[keys(var.hubs)[count.index]].location
  virtual_wan_id      = azurerm_virtual_wan.virtualWan.id
  address_prefix      = var.hubs[keys(var.hubs)[count.index]].addressPrefix
}

resource "time_sleep" "wait_300_seconds" {
  depends_on      = [azurerm_virtual_hub.virtualHub]
  create_duration = "300s"
}

resource "azurerm_vpn_gateway" "s2sGateway" {
  depends_on = [time_sleep.wait_300_seconds]
  for_each   = { for k, hub in var.hubs : k => hub if contains(keys(hub), "s2sGatewayName") }

  name                = each.value.s2sGatewayName
  resource_group_name = var.resourceGroup
  location            = each.value.location
  virtual_hub_id      = azurerm_virtual_hub.virtualHub[index(keys(var.hubs), each.key)].id
  scale_unit          = each.value.s2sGatewayScaleUnits
}

resource "azurerm_vpn_server_configuration" "p2sGatewayConfig" {
  for_each = { for k, hub in var.hubs : k => hub if contains(keys(hub), "p2sGatewayName") }

  name                     = "${each.value.p2sGatewayName}-config"
  resource_group_name      = var.resourceGroup
  location                 = each.value.location
  vpn_authentication_types = ["AAD"]

  azure_active_directory_authentication {
    audience = each.value.p2sGatewayAudience
    issuer   = each.value.p2sGatewayIssuer
    tenant   = each.value.p2sGatewayTenant
  }
}

resource "azurerm_point_to_site_vpn_gateway" "p2sGateway" {
  depends_on = [time_sleep.wait_300_seconds]
  for_each   = { for k, hub in var.hubs : k => hub if contains(keys(hub), "p2sGatewayName") }

  name                        = each.value.p2sGatewayName
  resource_group_name         = var.resourceGroup
  location                    = each.value.location
  virtual_hub_id              = azurerm_virtual_hub.virtualHub[index(keys(var.hubs), each.key)].id
  vpn_server_configuration_id = azurerm_vpn_server_configuration.p2sGatewayConfig[each.key].id
  scale_unit                  = each.value.p2sGatewayScaleUnits

  connection_configuration {
    name = "${each.value.p2sGatewayName}-config"
    vpn_client_address_pool {
      address_prefixes = [each.value.p2sGatewayAddressPrefix]
    }
  }
}

resource "azurerm_express_route_gateway" "erGateway" {
  depends_on = [time_sleep.wait_300_seconds]
  for_each   = { for k, hub in var.hubs : k => hub if contains(keys(hub), "erGatewayName") }

  name                = each.value.erGatewayName
  resource_group_name = var.resourceGroup
  location            = each.value.location
  virtual_hub_id      = azurerm_virtual_hub.virtualHub[index(keys(var.hubs), each.key)].id
  scale_units         = each.value.erGatewayScaleUnits
}
