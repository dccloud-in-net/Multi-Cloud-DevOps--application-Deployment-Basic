# ==============================================================================
# Azure Network Infrastructure (Resource Group, VNet & Subnets)
# ==============================================================================

# Create Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Create Virtual Network (VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = "bankpro-${var.environment}-vnet"
  address_space       = var.vnet_cidr
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Create Subnets using for_each
resource "azurerm_subnet" "subnet" {
  for_each             = var.subnets
  name                 = "bankpro-${var.environment}-subnet-${each.key}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes
}

# ==============================================================================
# Network Security Groups (NSG) & Rules
# ==============================================================================

# Create NSG
resource "azurerm_network_security_group" "nsg" {
  name                = "bankpro-${var.environment}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Allow public HTTP
  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow public HTTPS
  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow SSH administrative access
  security_rule {
    name                       = "Allow-SSH"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*" # Can restrict in production
    destination_address_prefix = "*"
  }

  # Allow Internal App traffic on 8080
  security_rule {
    name                       = "Allow-AppPort"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Associate NSG with Subnets (Associate with all subnets in the loop)
resource "azurerm_subnet_network_security_group_association" "subnet_assoc" {
  for_each                  = azurerm_subnet.subnet
  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# ==============================================================================
# Azure Container Registry (ACR)
# ==============================================================================

# Create ACR for Docker Images
resource "azurerm_container_registry" "acr" {
  count = var.create_acr ? 1 : 0
  # ACR name must be alphanumeric globally unique and between 5-50 characters
  name                = "bankproregistry${var.environment}sub"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.acr_sku
  admin_enabled       = true # Required for simple GHA/Ansible credentials

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
