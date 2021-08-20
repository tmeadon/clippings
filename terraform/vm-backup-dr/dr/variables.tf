variable "resource_groups" {
  type = object(
    {
      primary   = string
      secondary = string
    }
  )
}

variable "locations" {
  type = object(
    {
      primary   = string
      secondary = string
    }
  )
}

variable "vault_name" {
  type = string
}

variable "vm_id" {
  type = string
}

variable "os_disk" {
  type = object(
    {
      id = string
      sku = string
    }
  )
}

variable "data_disk" {
  type = object(
    {
      id = string
      sku = string
    }
  )
}

variable "nic_id" {
  type = string
}

variable "target_network_id" {
  type = string
}

variable "target_subnet_name" {
  type = string
}

variable "target_pip_id" {
  type = string
}

variable "target_resource_group_id" {
  type = string
}

locals {
  vm_id_split = split("/", var.vm_id)
}

locals {
  vm_name = element(local.vm_id_split, length(local.vm_id_split)-1)
}
