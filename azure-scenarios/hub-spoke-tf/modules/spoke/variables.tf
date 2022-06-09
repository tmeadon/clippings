variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet" {
  type = object({
    name           = string
    address_prefix = string
    subnets = list(object({
      name           = string
      address_prefix = string
    }))
  })
}

variable "hub" {
  type = object({
    vnet_name                = string
    vnet_resource_group_name = string
    vnet_id                  = string
    has_gateway              = bool
  })
}