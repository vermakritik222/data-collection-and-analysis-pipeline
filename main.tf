# Resource group
resource "azurerm_resource_group" "rg" {
  name     = "${local.project_prifix}_${local.project_location}_resource_group"
  location = local.project_location
}

# Public Ips
resource "azurerm_public_ip" "app_gateway_public_ip" {
  name                = "${local.project_prifix}_public_ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Virtual Networks
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.project_prifix}_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  # dns_servers         = ["10.0.0.4", "10.0.0.5"]
}

# Subnet
resource "azurerm_subnet" "data_subnet_nsg" {
  name                 = "${local.project_prifix}_subnet_data"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}


# Network Security Group
resource "azurerm_network_security_group" "data_subnet_nsg" {
  name                = "${local.project_prifix}_nsg_data"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = ["0.0.0.0/0"]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = ["0.0.0.0/0"]
    destination_address_prefix = "*"
  }

}

# Network Security Group Assocuation
resource "azurerm_subnet_network_security_group_association" "association_data_nsg" {
  subnet_id                 = azurerm_subnet.data_subnet_nsg.id
  network_security_group_id = azurerm_network_security_group.data_subnet_nsg.id
}

// azurerm_storage_account
resource "azurerm_storage_account" "example" {
  name                = "storageaccountname"
  resource_group_name = azurerm_resource_group.rg.name

  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  is_hns_enabled           = true

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["100.0.0.1"]
    virtual_network_subnet_ids = [azurerm_subnet.data_subnet_nsg.id]
  }

  tags = {
    environment = "staging"
  }
}
