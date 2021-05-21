provider "azurerm" {
  version = "2.14.0"
  features {}
}

data "http" "localPublicIp" {
  url = "http://ifconfig.me/ip"
}
