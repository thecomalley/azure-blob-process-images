module "naming" {
  source      = "Azure/naming/azurerm"
  suffix      = ["abpi"]
  unique-seed = "abpi"
}
resource "azurerm_resource_group" "example" {
  name     = module.naming.resource_group.name
  location = "Australia East"
  tags     = var.tags
}

resource "azurerm_storage_account" "example" {
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags                     = var.tags

}

resource "azurerm_storage_container" "images" {
  name                  = "images"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "thumbnails" {
  name                  = "thumbnails"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

resource "azurerm_app_service_plan" "example" {
  name                = "asp-f1-abpi"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags
  kind                = "Linux"


  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "example" {
  name                = "app-abpi-frontend"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id
  tags                = var.tags

  app_settings = {
    "AZURE_STORAGE_ACCOUNT_NAME"       = azurerm_storage_account.example.name
    "AZURE_STORAGE_ACCOUNT_ACCESS_KEY" = azurerm_storage_account.example.primary_access_key
    "SCM_COMMAND_IDLE_TIMEOUT"         = "300"
  }

}

resource "azurerm_storage_account" "functions" {
  name                     = "stabpifunctions"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags                     = var.tags

}

resource "azurerm_function_app" "example" {
  name                       = "function-abpi-resizing"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  app_service_plan_id        = azurerm_app_service_plan.example.id
  storage_account_name       = azurerm_storage_account.functions.name
  storage_account_access_key = azurerm_storage_account.functions.primary_access_key
  tags                       = var.tags

  app_settings = {
    "THUMBNAIL_CONTAINER_NAME"    = "thumbnails"
    "THUMBNAIL_WIDTH"             = "100"
    "FUNCTIONS_EXTENSION_VERSION" = "2"
  }

}