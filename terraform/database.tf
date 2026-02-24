resource "azurerm_cosmosdb_account" "resume-challenge-ac" {
  name                = "cosmosdb-resume-challenge"
  location            = azurerm_resource_group.resume-challenge.location
  resource_group_name = azurerm_resource_group.resume-challenge.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  public_network_access_enabled = false

  consistency_policy {
    consistency_level = "Session"
  }

  capabilities {
    name = "EnableServerless"
  }

  geo_location {
    location          = azurerm_resource_group.resume-challenge.location
    failover_priority = 0
  }

  tags = {
    environment = "Production"
    project     = "ResumeChallenge" 
  }
  
}

resource "azurerm_cosmosdb_sql_database" "resume-challenge-db" {
  name                = "resume-challenge-db"
  resource_group_name = azurerm_resource_group.resume-challenge.name
  account_name        = azurerm_cosmosdb_account.resume-challenge-ac.name
  
}

resource "azurerm_cosmosdb_sql_container" "visitor-counter" {
    name                = "visitor-counter"
    resource_group_name = azurerm_resource_group.resume-challenge.name
    account_name        = azurerm_cosmosdb_account.resume-challenge-ac.name
    database_name       = azurerm_cosmosdb_sql_database.resume-challenge-db.name
    partition_key_paths  = ["/id"]
    
    }
