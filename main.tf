provider "azurerm" {
  features {}
}

module "PromoteDC" {
  source                        = "./Modules/Promote-DC"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  vmname                        = azurerm_windows_virtual_machine.dc01.name
  vmid                          = azurerm_windows_virtual_machine.dc01.id
  active_directory_domain       = var.ADDomainName
  admin_password                = var.ADDomainPassword
  active_directory_netbios_name = var.ADDomainNetbios
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = "UK South"

  tags = {
    environment = "NTC-AVD-Lab"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_servers         = ["10.2.0.5"]
}

resource "azurerm_subnet" "internal" {
  name                 = "VM-Subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.2.0.0/24"]
}

resource "azurerm_network_interface" "dc01nic" {
  name                = "${var.prefix}-dc01nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

    ip_configuration {
    name                          = "dc01nicconf"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.2.0.5"
    public_ip_address_id          = azurerm_public_ip.dc01pubip.id
  }
}

resource "azurerm_public_ip" "dc01pubip" {
  name                = "${var.prefix}-dc01pubip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
}

resource "azurerm_windows_virtual_machine" "dc01" {
  name                = "${var.prefix}-dc01"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B2ms"
  admin_username      = var.ADDomainUser
  admin_password      = var.ADDomainPassword
    network_interface_ids = [
    azurerm_network_interface.dc01nic.id,
  ]

  tags = {
    environment = "NTC-AVD-Lab"
    admin-user = "${var.ADDomainUser}"
    admin-pswd = "${var.ADDomainPassword}"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}