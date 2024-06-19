resource "azurerm_container_registry" "this" {
  name                = "acr${var.service}${var.environment}${var.location}${var.instance}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.acr_sku
  admin_enabled       = true
}
