terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0, < 4.0"
    }
  }
  backend "azurerm" {
    key = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

