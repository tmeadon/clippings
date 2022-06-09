module "uks_hub" {
  source              = "./modules/hub"
  location            = "uksouth"
  resource_group_name = "hub-uks"
  vnet = {
    address_prefix = "10.0.0.0/24"
    name           = "vnet-hub-uks"
  }
  firewall = {
    subnet_address_prefix = "10.0.0.0/26"
  }
  vpn_gateway = {
    subnet_address_prefix = "10.0.0.64/26"
  }
}

module "uks_spoke" {
  source              = "./modules/spoke"
  location            = "uksouth"
  resource_group_name = "spoke-uks"
  vnet = {
    name           = "vnet-spoke-uks"
    address_prefix = "10.0.1.0/24"
    subnets = [
      {
        address_prefix = "10.0.1.0/26"
        name           = "dmz"
      },
      {
        address_prefix = "10.0.1.64/26"
        name           = "frontend"
      },
      {
        address_prefix = "10.0.1.128/26"
        name           = "backend"
      }
    ]
  }
  hub = {
    vnet_resource_group_name = module.uks_hub.vnet_resource_group_name
    vnet_name                = module.uks_hub.vnet_name
    vnet_id                  = module.uks_hub.vnet_id
    has_gateway              = false
  }
}