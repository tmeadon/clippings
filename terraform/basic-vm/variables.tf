variable "name" {
  type = string
  description = "name for the deployment"
}

variable "os" {
  type = string
  description = "os for the vm(s) - should be one of 'windows', 'centos', 'ubuntu-server'"
}

variable "spot" {
    type = bool
    description = "set to true to deploy a spot vm"
}

variable "vm-password" {
    type = string
    description = "password for the vm"
}