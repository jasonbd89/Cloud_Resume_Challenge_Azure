output "primary_web_endpoint" {
  description = "The URL of the static website."
  value       = azurerm_storage_account.resume-challenge.primary_web_endpoint
}

output "function_api_url" {
  value = "https://${azurerm_linux_function_app.visitor_counter.default_hostname}/api/visitors"
  
}
output "application_insights_connection_string" {
  value = azurerm_application_insights.func_app_insights.connection_string
}