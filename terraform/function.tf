resource "azurerm_service_plan" "func_plan" {
  name                = "sp-resume-challenge"
  resource_group_name = azurerm_resource_group.resume-challenge.name
  location            = "westeurope"
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "visitor_counter" {
  name                = "func-visitor-counter-resume-022025"
  resource_group_name = azurerm_resource_group.resume-challenge.name
  location            = "westeurope"

  storage_account_name       = azurerm_storage_account.func_storage.name
  storage_account_access_key = azurerm_storage_account.func_storage.primary_access_key
  service_plan_id            = azurerm_service_plan.func_plan.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      python_version = "3.10"
    }
    cors {
      allowed_origins = [trim(azurerm_storage_account.resume-challenge.primary_web_endpoint, "/")]
    }
  }

  app_settings = {
    "COSMOS_ENDPOINT"              = azurerm_cosmosdb_account.resume-challenge-ac.endpoint
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "false"
    "ENABLE_ORYX_BUILD"            = "true"
    "FUNCTIONS_WORKER_RUNTIME"     = "python"
    "AzureWebJobsFeatureFlags"     = "EnableWorkerIndexing"
  }
}

# resource "azurerm_cosmosdb_sql_role_assignment" "func_to_cosmos" {
#   resource_group_name = azurerm_resource_group.resume-challenge.name
#   account_name        = azurerm_cosmosdb_account.resume-challenge-ac.name
#   role_definition_id  = "${azurerm_cosmosdb_account.resume-challenge-ac.id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
#   principal_id        = azurerm_linux_function_app.visitor_counter.identity[0].principal_id
#   scope               = azurerm_cosmosdb_account.resume-challenge-ac.id
# }
