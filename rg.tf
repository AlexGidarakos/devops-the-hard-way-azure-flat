# Main Resource Group
resource "azurerm_resource_group" "main_rg" {
  name     = "${var.name}-rg"
  location = var.location
}
