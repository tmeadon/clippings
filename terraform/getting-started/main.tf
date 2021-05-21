provider "azurerm" {
  version = "1.38.0"
}

terraform {
  backend "azurerm" {
    resource_group_name = "tf-management"
    storage_account_name = "tfmanagement"
    container_name = "tfstate"
    key = "getting-started.tfstate"
  }
}

variable "vm-password" {
  type = string
}

resource "azurerm_resource_group" "rg" {
  name      = "tf-getting-started"
  location  = "uksouth"
}

module "network" {
  source = "../modules/azure/vnet"
  vnet-name = "tf-vnet"
  vnet-address-space =  ["10.0.0.0/16"]
  subnets = [
    {
      subnet-name = "vm-subnet"
      subnet-address-prefix = "10.0.1.0/24"
    }
  ]
  resource-group = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
}

resource "azurerm_public_ip" "vm-pip" {
  name = "vm-pip"
  allocation_method = "Static"
  sku = "Basic"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_group" "vm-nsg" {
  name = "vm-nsg"
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

module "ubuntu-vms" {
  source = "../modules/azure/vms"
  os = "ubuntu-server"
  size = "Standard_DS1_v2"
  name-prefix = "ubuntu"
  num-instances = 3
  credentials = {
    username = "tom"
    password = var.vm-password
  }
  nsg-id = azurerm_network_security_group.vm-nsg.id
  subnet-id = module.network.subnets["vm-subnet"]
  resource-group = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
}