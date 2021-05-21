variable "os" {
  type        = string
  description = "os for the vm(s) - should be one of 'windows', 'centos', 'ubuntu-server'"
}

variable "size" {
  type        = string
  description = "vm size (e.g. 'Standard_DS1_v2')"
  default     = "Standard_DS1_v2"
}

variable "namePrefix" {
  type        = string
  description = "prefix for the name(s)"
}

variable "numInstances" {
  type        = number
  description = "number of vms to provision"
}

variable "credentials" {
  type = object(
    {
      username = string
      password = string
    }
  )
  description = "credentials for the provisioned vms"
}

variable "subnetId" {
  type        = string
  description = "id for the subnet to deploy the vm into"
}

variable "resourceGroup" {
  type        = string
  description = "resource group to deploy into"
}

variable "location" {
  type        = string
  description = "azure region to deploy into"
}

variable "createPublicIp" {
  type        = bool
  description = "bool to specify whether a public IP should be created for each VM"
  default     = false
}

