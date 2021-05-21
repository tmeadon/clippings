variable "resourceGroup" {
  type        = string
  description = "resource group to deploy into"
}

variable "vwanName" {
  type        = string
  description = "name for the virtual wan resource"
}

variable "vwanLocation" {
  type        = string
  description = "location for the virtual wan resource"
}

variable "allowVnetToVnetTraffic" {
  type        = bool
  description = "allow traffic to flow between vnets"
  default     = true
}

variable "hubs" {
  type        = map(map(string))
  description = <<EOT
  A map containing a map for each hub to be deployed.  Each individual hub map should have the following keys:
  - name
  - location
  - addressPrefix
  - [Optional - to deploy a S2S gateway] s2sGatewayName; s2sGatewayScaleUnits
  - [Optional - to deploy a P2S gateway] p2sGatewayName; p2sGatewayAudience; p2sGatewayIssuer; p2sGatewayTenant; p2sGatewayScaleUnits; p2sGatewayAddressPrefix (single prefix only)
  - [Optional - to deploy an ER gateway] erGatewayName; erGatewayScaleUnits
  EOT
}