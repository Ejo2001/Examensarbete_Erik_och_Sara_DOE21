terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}


resource "azurerm_resource_group" "examengroup" {
  name     = "examensarbete"
  location = "West Europe"
}


resource "azurerm_public_ip" "vm_external_ip" {
  name                = "public_ip_address"
  resource_group_name = azurerm_resource_group.examengroup.name
  location            = azurerm_resource_group.examengroup.location
  allocation_method   = "Static"
}

resource "azurerm_virtual_network" "examen_network" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.examengroup.location
  resource_group_name = azurerm_resource_group.examengroup.name
}

resource "azurerm_subnet" "examen_subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.examengroup.name
  virtual_network_name = azurerm_virtual_network.examen_network.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_network_interface" "examen_interface" {
  name                = "examens_NIC"
  location            = azurerm_resource_group.examengroup.location
  resource_group_name = azurerm_resource_group.examengroup.name

  ip_configuration {
    name                          = "internal_network"
    subnet_id                     = azurerm_subnet.examen_subnet.id
    private_ip_address = "10.0.2.100"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vm_external_ip.id
  }
}











resource "azurerm_linux_virtual_machine" "examen_VM" {
  name                = "examens_arbete_VM"
  resource_group_name = azurerm_resource_group.examengroup.name
  location            = azurerm_resource_group.examengroup.location
  size                = "Standard_B1ls"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.examen_interface.id,
  ]

  
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("${path.cwd}/examensarbete_key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.examen_interface
  ]
}