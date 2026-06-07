# ==============================================================================
# Azure Load Balancer Setup
# ==============================================================================

# Public IP for Azure Load Balancer
resource "azurerm_public_ip" "lb_pip" {
  name                = "bankpro-${var.environment}-lb-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Azure Load Balancer
resource "azurerm_lb" "app_lb" {
  name                = "bankpro-${var.environment}-lb"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Backend Address Pool
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.app_lb.id
  name            = "BackEndAddressPool"
}

# Health Probe on application port 8080
resource "azurerm_lb_probe" "hp" {
  loadbalancer_id = azurerm_lb.app_lb.id
  name            = "http-running-probe"
  port            = 8080
  protocol        = "Http"
  request_path    = "/"
}

# Load Balancer Rule (Port 80 to Port 8080)
resource "azurerm_lb_rule" "lb_rule" {
  loadbalancer_id                = azurerm_lb.app_lb.id
  name                           = "LBRule-HTTP"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 8080
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                       = azurerm_lb_probe.hp.id
}

# ==============================================================================
# Azure Compute VMs (Ubuntu Instances)
# ==============================================================================

# Public IPs for VM direct admin connections (Optional, but useful for Ansible SSH)
# In high security, we'd use Azure Bastion, but public IP with NSG restriction is common for testing.
resource "azurerm_public_ip" "vm_pip" {
  count               = var.vm_count
  name                = "bankpro-${var.environment}-vm-pip-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# VM Network Interfaces (NIC)
resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "bankpro-${var.environment}-vm-nic-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip[count.index].id
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Associate NICs with Load Balancer Backend Address Pool
resource "azurerm_network_interface_backend_address_pool_association" "nic_lb_assoc" {
  count                   = var.vm_count
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
}

# Virtual Machine Instance
resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.vm_count
  name                = "bankpro-${var.environment}-vm-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # Enable Managed Identity
  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment
    Role        = "Application"
    ManagedBy   = "Terraform"
  }
}
