output "vwanId" {
  description = "ID of the VWAN resource"
  value       = azurerm_virtual_wan.virtualWan.id
}

output "hubIds" {
  description = "Map containing hub IDs"
  value       = { for k, hub in var.hubs : k => azurerm_virtual_hub.virtualHub[index(keys(var.hubs), k)].id }
}

output "s2sGatewayIds" {
  description = "Map containing s2s gateway IDs"
  value       = { for k, hub in var.hubs : k => azurerm_vpn_gateway.s2sGateway[k].id if contains(keys(hub), "s2sGatewayName") }
}

output "p2sGatewayIds" {
  description = "Map containing p2s gateway IDs"
  value       = { for k, hub in var.hubs : k => azurerm_point_to_site_vpn_gateway.p2sGateway[k].id if contains(keys(hub), "p2sGatewayName") }
}

output "erGatewayIds" {
  description = "Map containing er gateway IDs"
  value       = { for k, hub in var.hubs : k => azurerm_express_route_gateway.erGateway[k].id if contains(keys(hub), "erGatewayName") }
}