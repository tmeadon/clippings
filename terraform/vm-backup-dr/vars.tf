variable "baseName" {
  type    = string
  default = "vm-rsv-test"
}

variable "primaryLocation" {
  type    = string
  default = "uksouth"
}

variable "secondaryLocation" {
  type    = string
  default = "northeurope"
}

variable "adminPassword" {
  type      = string
  sensitive = true
}

variable "dscUrl" {
  type = string
}

variable "dscUrlSasToken" {
  type      = string
  sensitive = true
}

locals {
  vmName = "vm1"
}
