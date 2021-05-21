resource "azurerm_resource_group" "site01" {
  name     = local.site01RgName
  location = local.site01Location
  tags     = local.tags
}

module "site01_vnet" {
  source = "../../../terraform/modules/azure/vnet"

  vnet-name          = local.site01VnetName
  resource-group     = azurerm_resource_group.site01.name
  location           = local.site01Location
  vnet-address-space = local.site01VnetAddressSpace
  subnets            = local.site01Subnets
}

resource "azurerm_virtual_hub_connection" "site01_vnet_connection" {
  name                      = "virtualHubConnection"
  virtual_hub_id            = module.virtualWan.hubIds[local.site01VnetVirtualHub]
  remote_virtual_network_id = module.site01_vnet.vnet-id
}

module "site01_vm" {
  source = "../../../terraform/modules/azure/vms"

  resourceGroup  = azurerm_resource_group.site01.name
  location       = local.site01Location
  namePrefix     = local.site01Vm1Name
  numInstances   = 1
  size           = "Standard_B1s"
  os             = "windows"
  subnetId       = module.site01_vnet.subnets[local.site01Vm1Subnet]
  credentials    = local.vmCredentials
  createPublicIp = true
}

resource "azurerm_network_security_group" "site01_nsg" {
  name                = local.site01NsgName
  location            = local.site01Location
  resource_group_name = azurerm_resource_group.site01.name

  security_rule {
    name                       = "allowRdp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "${data.http.localPublicIp.body}/32"
    destination_address_prefix = local.site01VnetAddressSpace[0]
  }
}

resource "azurerm_subnet_network_security_group_association" "site01NsgSubnetAssociation" {
  subnet_id                 = module.site01_vnet.subnets[local.site01Vm1Subnet]
  network_security_group_id = azurerm_network_security_group.site01_nsg.id
}