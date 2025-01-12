#sentinel - Deploy Azure Sentinel and Log Analytics Workspace

resource "azurerm_resource_group" "sentinel_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "sentinel_workspace" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.sentinel_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_security_center_subscription_pricing" "sentinel_security_center_pricing" {
  tier            = "Standard"
  subscription_id = var.subscription_id
}

# Conditional deployment for Azure Private Link
resource "azurerm_private_endpoint" "sentinel_private_endpoint" {
  count                    = var.deploy_private_link ? 1 : 0
  name                     = "sentinel-private-endpoint"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.sentinel_rg.name
  subnet_id                = var.private_subnet_id

  private_service_connection {
    name                           = "sentinel-private-connection"
    private_connection_resource_id = azurerm_log_analytics_workspace.sentinel_workspace.id
    is_manual_connection           = false
  }
}
