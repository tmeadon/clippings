provider "azurerm" {
  version = "2.0.0"
  features {}
}

resource "azurerm_resource_group" "rg" {
  name      = "${var.name}-rg"
  location  = "uksouth"
}

module "network" {
  source = "../modules/azure/vnet"
  vnet-name = "${var.name}-vnet"
  vnet-address-space =  ["10.0.0.0/16"]
  subnets = [
    {
      subnet-name = "${var.name}-subnet"
      subnet-address-prefix = "10.0.1.0/24"
    }
  ]
  resource-group = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
}

resource "azurerm_public_ip" "vm-pip" {
  name = "${var.name}-pip"
  allocation_method = "Static"
  sku = "Basic"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_group" "vm-nsg" {
  name = "${var.name}-nsg"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name = "ssh"
    priority = 1001
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

module "vm" {
  source = "../modules/azure/vms"
  os = var.os
  size = "Standard_DS1_v2"
  name-prefix = var.name
  num-instances = 1
  credentials = {
    username = "tom"
    password = var.vm-password
  }
  nsg-id = azurerm_network_security_group.vm-nsg.id
  subnet-id = module.network.subnets["${var.name}-subnet"]
  resource-group = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
}