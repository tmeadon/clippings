provider "azurerm" {
  version = "2.0.0"
  features {}
}

resource "azurerm_resource_group" "rg" {
  name      = var.name
  location  = "uksouth"
}

module "virtual-wan" {
  source = "../modules/azure/virtual-wan"
  name = "virtual-wan"
  resourceGroup = azurerm_resource_group.rg.name
  vwanLocation = "uksouth"

  hubs = [
    {
      name = "uksouth"
      location = "uksouth"
      addressPrefix = "10.0.0.0/24"
    }
  ]
}

