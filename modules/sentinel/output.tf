output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.sentinel_workspace.id
}

output "sentinel_resource_group" {
  value = azurerm_resource_group.sentinel_rg.name
}
