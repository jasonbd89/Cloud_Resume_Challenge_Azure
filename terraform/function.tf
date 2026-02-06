resource "azurerm_service_plan" "func_plan" {
  name                = "asp-resume-challenge"
  resource_group_name = azurerm_resource_group.resume-challenge.name
  location            = azurerm_resource_group.resume-challenge.location
  os_type             = "Linux"
  sku_name            = "Y1" # Consumption plan
}

resource "azurerm_linux_function_app" "visitor_counter" {
  name                = "func-resume-challenge-022025"
  resource_group_name = azurerm_resource_group.resume-challenge.name
  location            = azurerm_resource_group.resume-challenge.location

  storage_account_name       = azurerm_storage_account.func_storage.name
  storage_account_access_key = azurerm_storage_account.func_storage.primary_access_key
  service_plan_id            = azurerm_service_plan.func_plan.id

  site_config {
    application_stack {
      python_version = "3.11"
    }
    cors {
      # Allow the static website to call this function. 
      # trimsuffix removes the trailing slash which CORS often dislikes.
      allowed_origins = [trimsuffix(azurerm_storage_account.resume-challenge.primary_web_endpoint, "/")]
      support_credentials = true
    }
  }

  app_settings = {
    "AzureResumeConnectionString" = azurerm_cosmosdb_account.resume-challenge-ac.primary_sql_connection_string
    "FUNCTIONS_WORKER_RUNTIME"    = "python"
    "CosmosDbDatabaseName"        = azurerm_cosmosdb_sql_database.resume-challenge-db.name
    "CosmosDbContainerName"       = azurerm_cosmosdb_sql_container.visitor-counter.name
  }
}
