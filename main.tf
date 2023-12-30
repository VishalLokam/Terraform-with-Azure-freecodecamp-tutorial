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


# This will create a new resource group in Azure
resource "azurerm_resource_group" "tf_az_rg_1" {
  name     = "tf_az_rg_1"
  location = "centralindia"
  tags = {
    environment = "dev"
  }
}


# This will create a new virtual network
resource "azurerm_virtual_network" "tf_az_vn_1" {
  name                = "tf_az_vn_1"
  resource_group_name = azurerm_resource_group.tf_az_rg_1.name
  location            = azurerm_resource_group.tf_az_rg_1.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}


# This will create a new subnet
resource "azurerm_subnet" "tf_az_subnet_1" {
  name                 = "tf_az_subnet_1"
  resource_group_name  = azurerm_resource_group.tf_az_rg_1.name
  virtual_network_name = azurerm_virtual_network.tf_az_vn_1.name
  address_prefixes     = ["10.123.1.0/24"]
}


# This will create a new security group
resource "azurerm_network_security_group" "tf_az_nsg_1" {
  name                = "tf_az_nsg_1"
  resource_group_name = azurerm_resource_group.tf_az_rg_1.name
  location            = azurerm_resource_group.tf_az_rg_1.location

  tags = {
    environment = "dev"
  }
}

# This will create a new NSG rule
resource "azurerm_network_security_rule" "tf_az_dev_rule_1" {
  name                        = "tf_az_dev_rule_1"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tf_az_rg_1.name
  network_security_group_name = azurerm_network_security_group.tf_az_nsg_1.name
}

# Associate NSG(tf_az_nsg_1) with Subnet(tf_az_subnet_1)
resource "azurerm_subnet_network_security_group_association" "tz_az_nsg_subnet_association_1" {
  subnet_id                 = azurerm_subnet.tf_az_subnet_1.id
  network_security_group_id = azurerm_network_security_group.tf_az_nsg_1.id
}

# Add a public address 
resource "azurerm_public_ip" "tf_az_public_ip_1" {
  name                = "tf_az_public_ip_1"
  resource_group_name = azurerm_resource_group.tf_az_rg_1.name
  location            = azurerm_resource_group.tf_az_rg_1.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

