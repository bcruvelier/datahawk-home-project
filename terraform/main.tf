terraform {
  required_version = ">= 0.14.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.39"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name      = "${var.project}-${var.environment}-resource-group"
  location  = var.location
  tags = {
    managed_by  = "terraform"
  }
}

resource "azurerm_storage_account" "function_storage_account" {
  name                      = "${var.project}-${var.environment}-functionstorage"
  resource_group_name       = azurerm_resource_group.resource_group.name
  location                  = azurerm_resource_group.resource_group.location
  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = var.account_replication_type[var.environment]
  min_tls_version           = "TLS1_2"
  tags = {
    managed_by  = "terraform"
  }
}

resource "azurerm_application_insights" "application_insights" {
  name                = "${var.project}-${var.environment}-application-insights"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  application_type    = "web"
  tags = {
    managed_by  = "terraform"
  }
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                  = "${var.project}-${var.environment}-app-service-plan"
  resource_group_name   = azurerm_resource_group.resource_group.name
  location              = azurerm_resource_group.resource_group.location
  kind                  = "elastic"
  reserved              = false
  sku {
    tier = "ElasticPremium"
    size = "EP1"
  }
  tags = {
    managed_by  = "terraform"
  }
}

resource "azurerm_function_app" "function_app" {
  name                       = "${var.project}-${var.environment}-function-app"
  resource_group_name        = azurerm_resource_group.resource_group.name
  location                   = azurerm_resource_group.resource_group.location
  app_service_plan_id        = azurerm_app_service_plan.app_service_plan.id
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "",
    "FUNCTIONS_WORKER_RUNTIME" = "node",
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.application_insights.instrumentation_key,
    "WEBSITE_NODE_DEFAULT_VERSION": "~14"
  }
  site_config {
    use_32_bit_worker_process = false
  }
  storage_account_name       = azurerm_storage_account.function_storage_account.name
  storage_account_access_key = azurerm_storage_account.function_storage_account.primary_access_key
  version                    = "~3"

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }
  tags = {
    managed_by  = "terraform"
  }
}
