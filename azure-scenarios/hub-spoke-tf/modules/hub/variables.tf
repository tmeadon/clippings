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
  })
}

variable "firewall" {
  type = object({
    subnet_address_prefix = string
  })
  default = null
}

variable "vpn_gateway" {
  type = object({
    subnet_address_prefix = string
  })
  default = null
}