resource "azurerm_storage_account" "resume-challenge" {
  name                     = "stresumechallenge022025"
  resource_group_name      = azurerm_resource_group.resume-challenge.name
  location                 = azurerm_resource_group.resume-challenge.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"
  access_tier = "Hot"

  tags = {
    environment = "Production"
    project     = "ResumeChallenge"
  }

}

resource "azurerm_storage_account_static_website" "resume-challenge" {
  storage_account_id = azurerm_storage_account.resume-challenge.id
  index_document     = "index.html"
  error_404_document = "404.html"
  
}

# We use a 'Data' block to find existing identity by name
data "azuread_service_principal" "github_id" {
  display_name = "github-terraform-identity"
}

# Now we link that identity to your NEW resume storage account
resource "azurerm_role_assignment" "resume_data_contributor" {
  scope                = azurerm_storage_account.resume-challenge.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_service_principal.github_id.object_id
}

resource "azurerm_storage_account" "func_storage" {
  name                     = "stfuncresume022025"
  resource_group_name      = azurerm_resource_group.resume-challenge.name
  location                 = azurerm_resource_group.resume-challenge.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}