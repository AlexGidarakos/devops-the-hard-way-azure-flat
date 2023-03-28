# The ACR
resource "azurerm_container_registry" "acr" {
  name                = "${var.name}acr"
  resource_group_name = azurerm_resource_group.main_rg.name
  location            = azurerm_resource_group.main_rg.location
  sku                 = "Standard"
  admin_enabled       = false

  # Push the Docker image that was created by 040-create-aad-group-and-docker-image.sh
  provisioner "local-exec" {
    command = "az acr login --name ${self.name} && docker tag uberapp ${self.login_server}/uberapp:v1 && docker push ${self.login_server}/uberapp:v1"
  }
}
