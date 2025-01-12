#Module 2: sentinel_role_assignments - Assign Roles to Users and Sentinel
# This module ensures that the necessary roles are assigned to users and Sentinel.

resource "azurerm_role_assignment" "sentinel_user_contributor" {
  principal_id         = var.user_object_id
  role_definition_name = "Contributor"
  scope                = var.resource_group_id
}

resource "azurerm_role_assignment" "sentinel_log_analytics_contributor" {
  principal_id         = azurerm_log_analytics_workspace.sentinel_workspace.identity.principal_id
  role_definition_name = "Log Analytics Contributor"
  scope                = azurerm_log_analytics_workspace.sentinel_workspace.id
}

resource "azurerm_role_assignment" "sentinel_security_reader" {
  principal_id         = azurerm_log_analytics_workspace.sentinel_workspace.identity.principal_id
  role_definition_name = "Security Reader"
  scope                = var.resource_group_id
}
