resource "azurerm_resource_group" "vwan" {
  name     = local.vwanRgName
  location = local.vwanLocation
  tags     = local.tags
}

module "virtualWan" {
  source = "../../../terraform/modules/azure/virtual-wan"

  resourceGroup = azurerm_resource_group.vwan.name
  vwanName      = local.vwanName
  vwanLocation  = local.vwanLocation
  hubs          = local.vwanHubs
}