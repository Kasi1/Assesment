
provider "azurerm" {
  version = "=2.5.0"
  subscription_id ="Subscription"
  tenant_id = "Tenant details"
  Client_id = " Cilent id"
  features {}
}

## Resource group Creation
resource "azurerm_resource_group" "rg" {
  name     = "TerraformTest"
  location = "eastus"
}



##Vnet creation
resource "azurerm_virtual_network" "vnet" {
  name                = "vNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

##  Creation of subnet1
resource "azurerm_subnet" "subnet1" {
  name                 = "Sub1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.1.0/16"
}


##  Creation of subnet2
resource "azurerm_subnet" "subnet2" {
  name                 = "Sub2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.2.0/24"
}

## Creation of NIC
resource "azurerm_network_interface" "NIC" {
  name                = "NIC1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "Sub1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}


## Creation of NIC2
resource "azurerm_network_interface" "NIC2" {
  name                = "NIC2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "Sub2"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
## VM Creation
resource "azurerm_windows_virtual_machine" "VM" {
  name                = "VM-1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
 
  network_interface_ids = [
    azurerm_network_interface.VM.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }


  resource "azurerm_windows_virtual_machine" "VM" {
  name                = "VM-2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
 
  network_interface_ids = [
    azurerm_network_interface.VM.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }


  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}



# Creating resource NSG
resource “azurerm_network_security_group” “nsg” {
name = "NSGroup"
location = azurerm_resource_group.rg.location
resource_group_name = azurerm_resource_group.rg.name

# Security rules allow 80

security_rule {
name = “Inbound”
priority = 100
direction = “Inbound”
access = “Allow”
protocol = “Tcp”
source_port_range = “80”
destination_port_range = “*”
source_address_prefix = “Allow port 80 ”
destination_address_prefix = “*”
}

# Security rules allow 443

security_rule {
name = “Inbound”
priority = 200
direction = “Inbound”
access = “Allow”
protocol = “Tcp”
source_port_range = “443”
destination_port_range = “*”
source_address_prefix = “Allow port 443 ”
destination_address_prefix = “*”
}

}
# Subnet and NSG association
resource “azurerm_subnet_network_security_group_association” “nsg_association” {
subnet_id = azurerm_subnet.subnet1.id
network_security_group_id = azurerm_network_security_group.nsg.id
}

# Subnet and NSG association
resource “azurerm_subnet_network_security_group_association” “nsg_association” {
subnet_id = azurerm_subnet.subnet2.id
network_security_group_id = azurerm_network_security_group.nsg.id
}
