locals {
  tags = {
    DestroyTime = "19:00"
  }
  deploymentName = "vwan2sites"
  site01Location = "uksouth"
  site02Location = "eastus"
}

locals {
  vwanRgName   = "${local.deploymentName}-vwan"
  vwanName     = "vwan"
  vwanLocation = local.site01Location
  vwanHubs = {
    hub-uks = {
      name                 = "hub-${local.site01Location}"
      location             = local.site01Location
      addressPrefix        = "10.0.1.0/24"
      s2sGatewayName       = "hub-${local.site01Location}-s2s"
      s2sGatewayScaleUnits = 1
      # p2sGatewayName          = "hub-${local.site01Location}-p2s"
      # p2sGatewayAudience      = "41b23e61-6c1e-4545-b367-cd054e0ed4b4"
      # p2sGatewayIssuer        = "https://sts.windows.net/a1a2578a-8fd3-4595-bb18-7d17df8944b0/"
      # p2sGatewayTenant        = "https://login.microsoftonline.com/a1a2578a-8fd3-4595-bb18-7d17df8944b0/"
      # p2sGatewayScaleUnits    = 1
      # p2sGatewayAddressPrefix = "192.168.0.0/24"
    }
    hub-eus = {
      name                 = "hub-${local.site02Location}"
      location             = local.site02Location
      addressPrefix        = "10.0.2.0/24"
      s2sGatewayName       = "hub-${local.site02Location}-s2s"
      s2sGatewayScaleUnits = 1
    }
  }

  site01RgName           = "${local.deploymentName}-site01"
  site01VnetName         = "vnet-site01"
  site01VnetAddressSpace = ["10.0.10.0/24"]
  site01Subnets = [
    {
      subnet-name           = "sn01"
      subnet-address-prefix = "10.0.10.0/25"
    }
  ]
  site01VnetVirtualHub = "hub-uks"
  site01NsgName        = "nsg-site01"
  site01Vm1Name        = "vm-site01"
  site01Vm1Subnet      = "sn01"

  site02RgName           = "${local.deploymentName}-site02"
  site02VnetName         = "vnet-site02"
  site02VnetAddressSpace = ["10.0.20.0/24"]
  site02Subnets = [
    {
      subnet-name           = "sn01"
      subnet-address-prefix = "10.0.20.0/25"
    }
  ]
  site02VnetVirtualHub = "hub-eus"
  site02NsgName        = "nsg-site02"
  site02Vm1Name        = "vm-site02"
  site02Vm1Subnet      = "sn01"

  vmCredentials = {
    username = "tom"
    password = "Pa55Word!"
  }
}
