output "function_app_name" {
  value = azurerm_function_app.function_app.name
}

output "function_app_default_hostname" {
  value = azurerm_function_app.function_app.default_hostname
}

output "function_app_masterkey" {
  value = data.azurerm_function_app_host_keys.function_app.master_key
  sensitive   = true
}
output "function_app_defaultkey" {
  value = data.azurerm_function_app_host_keys.function_app.default_function_key
  sensitive   = true
}

output "instrumentation_key" {
  value = azurerm_application_insights.application_insights.instrumentation_key
  sensitive = true
}

output "function_storage_name" {
  value = local.function_storage_name
}

output "function_storage_primary_blob_connection_string" {
  value = azurerm_storage_account.function.primary_blob_connection_string
  sensitive = true
}