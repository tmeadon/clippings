variable "vnet-name" {
  type        = string
  description = "name for the vnet resource"
}

variable "vnet-address-space" {
  type        = list
  default     = ["10.0.0.0/16"]
  description = "address space for the vnet resource"
}

variable "resource-group" {
  type        = string
  description = "resource group for the vnet"
}

variable "location" {
  type        = string
  description = "location for the vnet"
}

variable "subnets" {
  type = list(object({
    subnet-name           = string
    subnet-address-prefix = string
  }))
  default = [
    {
      subnet-name           = "default-subnet"
      subnet-address-prefix = "10.0.1.0/24"
    }
  ]
}