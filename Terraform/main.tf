locals {
  naming_convention   = "${var.service}-${var.environment}-${var.location}-${var.instance}"
  resource_group_name = "rg-${local.naming_convention}"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location
}

