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

  # 1. Enable Managed Identity so DefaultAzureCredential works
  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      python_version = "3.11" # Matches your GitHub Actions now
    }
    cors {
      allowed_origins     = [trimsuffix(azurerm_storage_account.resume-challenge.primary_web_endpoint, "/")]
      support_credentials = true
    }
  }

  app_settings = {
    "COSMOS_ENDPOINT"                = azurerm_cosmosdb_account.resume-challenge-ac.endpoint
    "DATABASE_NAME"                  = "resume-challenge-db"
    "CONTAINER_NAME"                 = "visitor-counter"
    "FUNCTIONS_WORKER_RUNTIME"       = "python"
    "AzureWebJobsFeatureFlags"       = "EnableWorkerIndexing"
    # This setting tells Azure to run the build process during deployment, which is necessary for Python functions to install dependencies correctly. 
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "ENABLE_ORYX_BUILD"              = "true"
    "WEBSITE_RUN_FROM_PACKAGE"       = "0"
  }

  lifecycle {
    ignore_changes = [
      # Tell Terraform to ignore these specific keys if GitHub adds/changes them
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      app_settings["WEBSITE_ENABLE_SYNC_UPDATE_SITE"],
      app_settings["WEBSITE_CONTENTAZUREFILECONNECTIONSTRING"],
      app_settings["WEBSITE_CONTENTSHARE"]
    ]
  }
}

# 4. REQUIRED: Grant the Function App permission to read/write Cosmos DB
# This assigns the "Cosmos DB Built-in Data Contributor" role
resource "azurerm_cosmosdb_sql_role_definition" "role_def" {
  resource_group_name = azurerm_resource_group.resume-challenge.name
  account_name        = azurerm_cosmosdb_account.resume-challenge-ac.name
  name                = "CosmosDBDataContributor"
  type                = "CustomRole"
  assignable_scopes   = [azurerm_cosmosdb_account.resume-challenge-ac.id]

  permissions {
    data_actions = [
      "Microsoft.DocumentDB/databaseAccounts/readMetadata",
      "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*",
      "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*"
    ]
  }
}

resource "azurerm_cosmosdb_sql_role_assignment" "func_access" {
  resource_group_name = azurerm_resource_group.resume-challenge.name
  account_name        = azurerm_cosmosdb_account.resume-challenge-ac.name
  role_definition_id  = azurerm_cosmosdb_sql_role_definition.role_def.id
  principal_id        = azurerm_linux_function_app.visitor_counter.identity[0].principal_id
  scope               = azurerm_cosmosdb_account.resume-challenge-ac.id
}

resource "azurerm_application_insights" "func_app_insights" {
  name                = "appi-resume-challenge"
  location            = azurerm_resource_group.resume-challenge.location
  resource_group_name = azurerm_resource_group.resume-challenge.name
  application_type    = "web"
}