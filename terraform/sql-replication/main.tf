resource "random_string" "name_suffix" {
  length  = 5
  special = false
}

data "http" "my_ip" {
  url = "https://ifconfig.me/ip"
}

locals {
  unique_name = "${var.base_name}${lower(random_string.name_suffix.result)}"
  sql_server_ids = [
    azurerm_mssql_server.primary.id,
    azurerm_mssql_server.secondary.id
  ]
}

resource "azurerm_resource_group" "rg" {
  name     = var.base_name
  location = var.regions.primary
  tags = {
    "DestroyTime" = "18:00"
  }
}

resource "azurerm_mssql_server" "primary" {
  resource_group_name          = azurerm_resource_group.rg.name
  name                         = local.unique_name
  location                     = var.regions.primary
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"
}

resource "azurerm_mssql_server" "secondary" {
  resource_group_name          = azurerm_resource_group.rg.name
  name                         = "${local.unique_name}-dr"
  location                     = var.regions.secondary
  version                      = "12.0"
  administrator_login          = "tom"
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"
}

resource "azurerm_mssql_database" "db" {
  name        = "tomdb"
  server_id   = azurerm_mssql_server.primary.id
  create_mode = "Default"
  sku_name    = "S2"
}

resource "azurerm_mssql_firewall_rule" "allow-client-ip" {
  count            = length(local.sql_server_ids)
  name             = "tom"
  server_id        = local.sql_server_ids[count.index]
  start_ip_address = data.http.my_ip.body
  end_ip_address   = data.http.my_ip.body
}

resource "azurerm_sql_failover_group" "group" {
  resource_group_name = azurerm_resource_group.rg.name
  name                = "${local.unique_name}-fg"
  server_name         = azurerm_mssql_server.primary.name
  databases           = [azurerm_mssql_database.db.id]

  partner_servers {
    id = azurerm_mssql_server.secondary.id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }
}