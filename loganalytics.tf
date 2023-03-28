# The Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "Log_Analytics_WorkSpace" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name                = "${var.name}-la"
  location            = var.location
  resource_group_name = azurerm_resource_group.main_rg.name
  sku                 = "PerGB2018"
}

# The Log Analytics Solution
resource "azurerm_log_analytics_solution" "Log_Analytics_Solution_ContainerInsights" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.Log_Analytics_WorkSpace.location
  resource_group_name   = azurerm_resource_group.main_rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.Log_Analytics_WorkSpace.id
  workspace_name        = azurerm_log_analytics_workspace.Log_Analytics_WorkSpace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}