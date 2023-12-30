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
resource "azurerm_resource_group" "tf_azure_rg_1" {
  name     = "tf_azure_rg_1"
  location = "centralindia"
  tags = {
    environment = "dev"
  }
}