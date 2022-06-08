terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.9.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.3.1"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.base_name
  location = var.location
}

resource "random_id" "random" {
  keepers = {
    "rg_name" = azurerm_resource_group.rg.name
  }
  byte_length = 8
}

locals {
  unique_name = lower(random_id.random.b64_url)
}

resource "azurerm_storage_account" "stg" {
  name                = local.unique_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "share" {
  name                 = "share"
  storage_account_name = azurerm_storage_account.stg.name
  quota                = 50
}

resource "azurerm_storage_share_file" "file" {
  name             = "testfile.txt"
  storage_share_id = azurerm_storage_share.share.id
  source           = "testfile.txt"
}

resource "azurerm_service_plan" "asp" {
  name                = var.base_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  os_type  = "Linux"
  sku_name = "Y1"
}

resource "azurerm_application_insights" "ai" {
  name                = var.base_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  application_type = "web"
}

resource "azurerm_linux_function_app" "func" {
  name                = var.base_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  storage_account_name       = azurerm_storage_account.stg.name
  storage_account_access_key = azurerm_storage_account.stg.primary_access_key
  service_plan_id            = azurerm_service_plan.asp.id

  site_config {
    application_insights_key               = azurerm_application_insights.ai.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.ai.connection_string

    application_stack {
      dotnet_version              = "6.0"
      use_dotnet_isolated_runtime = true
    }
  }

  provisioner "local-exec" {
    command = <<EOF
az webapp config storage-account add --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_linux_function_app.func.name} \
--custom-id 'test-share' --storage-type AzureFiles --share-name ${azurerm_storage_share.share.name} --account-name ${azurerm_storage_account.stg.name} \
--mount-path "/test-share" --access-key ${azurerm_storage_account.stg.primary_access_key}
EOF
  }
}

