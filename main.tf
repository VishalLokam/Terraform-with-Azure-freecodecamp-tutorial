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

# This will create a new NIC
resource "azurerm_network_interface" "tf_az_nic_1" {
  name                = "tf_az_nic_1"
  location            = azurerm_resource_group.tf_az_rg_1.location
  resource_group_name = azurerm_resource_group.tf_az_rg_1.name

  ip_configuration {
    name                          = "ipconfig_1"
    subnet_id                     = azurerm_subnet.tf_az_subnet_1.id
    private_ip_address_allocation = "Dynamic"
    # associating public ip with this NIC
    public_ip_address_id = azurerm_public_ip.tf_az_public_ip_1.id
  }

  tags = {
    environment = "dev"
  }

}


# This will create a new virtual machine
resource "azurerm_linux_virtual_machine" "tf_az_vm_1" {
  name                = "tfazvm1"
  resource_group_name = azurerm_resource_group.tf_az_rg_1.name
  location            = azurerm_resource_group.tf_az_rg_1.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.tf_az_nic_1.id,
  ]

  custom_data = filebase64("customdata.tpl")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/tf_az_ssh_key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = templatefile( "${var.host_os}-ssh-script.tpl", {
      hostname = self.public_ip_address,
      user = "adminuser"
      identityfile = "~/.ssh/tf_az_ssh_key"
    })

    # interpreter = [ "Powershell", "-Command" ]
    # for linux or mac
    # interpreter = ["bash","-c"]

    # condition interpreter based on os variable
    interpreter = var.host_os == "windows" ? [ "Powershell", "-Command" ] : ["bash","-c"]
    
  
  }

  tags = {
    environment = "dev"
  }
}


data "azurerm_public_ip" "tf_az_ip_data_1" {
  name = azurerm_public_ip.tf_az_public_ip_1.name
  resource_group_name = azurerm_resource_group.tf_az_rg_1.name
}

output "tf_az_op_public_ip_1" {
  value = "${azurerm_linux_virtual_machine.tf_az_vm_1.name}: ${data.azurerm_public_ip.tf_az_ip_data_1.ip_address}"
}
