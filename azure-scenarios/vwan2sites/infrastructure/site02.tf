resource "azurerm_resource_group" "site02" {
  name     = local.site02RgName
  location = local.site02Location
  tags     = local.tags
}

module "site02_vnet" {
  source = "../../../terraform/modules/azure/vnet"

  vnet-name          = local.site02VnetName
  resource-group     = azurerm_resource_group.site02.name
  location           = local.site02Location
  vnet-address-space = local.site02VnetAddressSpace
  subnets            = local.site02Subnets
}

resource "azurerm_virtual_hub_connection" "site02_vnet_connection" {
  name                      = "virtualHubConnection"
  virtual_hub_id            = module.virtualWan.hubIds[local.site02VnetVirtualHub]
  remote_virtual_network_id = module.site02_vnet.vnet-id
}

module "site02_vm" {
  source = "../../../terraform/modules/azure/vms"

  resourceGroup  = azurerm_resource_group.site02.name
  location       = local.site02Location
  namePrefix     = local.site02Vm1Name
  numInstances   = 1
  size           = "Standard_B1s"
  os             = "windows"
  subnetId       = module.site02_vnet.subnets[local.site02Vm1Subnet]
  credentials    = local.vmCredentials
  createPublicIp = true
}

resource "azurerm_network_security_group" "site02_nsg" {
  name                = local.site02NsgName
  location            = local.site02Location
  resource_group_name = azurerm_resource_group.site02.name

  security_rule {
    name                       = "allowRdp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "${data.http.localPublicIp.body}/32"
    destination_address_prefix = local.site02VnetAddressSpace[0]
  }
}

resource "azurerm_subnet_network_security_group_association" "site02NsgSubnetAssociation" {
  subnet_id                 = module.site02_vnet.subnets[local.site02Vm1Subnet]
  network_security_group_id = azurerm_network_security_group.site02_nsg.id
}