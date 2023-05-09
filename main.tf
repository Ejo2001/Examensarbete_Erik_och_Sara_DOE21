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


resource "azurerm_public_ip" "vm-external-ip" {
  name                = "public-ip-address"
  resource_group_name = azurerm_resource_group.examengroup.name
  location            = azurerm_resource_group.examengroup.location
  allocation_method   = "Static"
}

resource "azurerm_virtual_network" "examen-network" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.examengroup.location
  resource_group_name = azurerm_resource_group.examengroup.name
}

resource "azurerm_subnet" "examen-subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.examengroup.name
  virtual_network_name = azurerm_virtual_network.examen-network.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_network_interface" "examen-interface" {
  name                = "examens_NIC"
  location            = azurerm_resource_group.examengroup.location
  resource_group_name = azurerm_resource_group.examengroup.name

  ip_configuration {
    name = "internal-network"
    subnet_id = azurerm_subnet.examen-subnet.id
    private_ip_address = "10.0.2.100"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vm-external-ip.id
  }
}











resource "azurerm_linux_virtual_machine" "examen-vm" {
  name                = "examens-arbete-VM"
  resource_group_name = azurerm_resource_group.examengroup.name
  location            = azurerm_resource_group.examengroup.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.examen-interface.id,
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
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.examen-interface
  ]
}

resource "local_file" "public_ip_txt" {
    content  = azurerm_public_ip.vm-external-ip.ip_address
    filename = "public_ip.txt"
}




data "azurerm_client_config" "current" {}

# data "azuread_user" "user"{
# user_principal_name = "erik.olsson@solidify.dev"
# }

resource "azurerm_key_vault" "exam_key_vault" {
  name                        = "ejoexamkeyvault"
  resource_group_name         = azurerm_resource_group.examengroup.name
  location                    = azurerm_resource_group.examengroup.location
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled = false 
  enable_rbac_authorization = false

  sku_name = "standard"

  access_policy { 
      tenant_id = data.azurerm_client_config.current.tenant_id 
      object_id = "f40f1509-d114-44bc-b317-de2055f5310b" #access_policy.value 
      secret_permissions = [ "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set", "Get" ] 
  }
}


# Set a secret
# resource "azurerm_key_vault_secret" "set_token" {
#   name         = "secretpassword"
#   value        = "secretpass!"
#   key_vault_id = azurerm_key_vault.exam_key_vault.id
# }

