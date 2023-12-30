terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.91.0"
    }
  }
}

provider "azurerm" {
  features {}
}


#This will create a new resource group in Azure
resource "azurerm_resource_group" "tf_az_rg_1" {
  name     = "tf_az_rg_1"
  location = "centralindia"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "tf_az_vn_1" {
  name                = "tf_az_vn_1"
  resource_group_name = azurerm_resource_group.tf_az_rg_1.name
  location            = azurerm_resource_group.tf_az_rg_1.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}
