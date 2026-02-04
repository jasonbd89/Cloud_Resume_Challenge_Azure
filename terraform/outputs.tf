output "primary_web_endpoint" {
  description = "The URL of the static website."
  value       = azurerm_storage_account.resume-challenge.primary_web_endpoint
}