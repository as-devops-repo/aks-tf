resource "azurerm_virtual_network" "this" {
  name                = "vnet-${local.naming_convention}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = var.address_space
}

resource "azurerm_subnet" "this" {
  name                 = "snet-${local.naming_convention}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.subnet_prefixes
  service_endpoints    = ["Microsoft.AzureCosmosDB"]
}
