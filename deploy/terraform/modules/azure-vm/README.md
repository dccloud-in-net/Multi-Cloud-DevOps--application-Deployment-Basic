# Azure VM Module

This module provisions Azure Virtual Machines and associates them with an Azure Load Balancer.

## Features
- Azure Load Balancer with Static Public IP.
- HTTP forwarding rule mapping Port 80 to Port 8080 (backend instances).
- NIC loop creations associated with Subnet & Backend Pools.
- Linux Virtual Machines running Ubuntu 22.04 LTS.
- Managed System Identity (MSI) enabled.

## Example Usage

```hcl
module "azure_vm" {
  source              = "../../modules/azure-vm"
  environment         = "dev"
  resource_group_name = "bankpro-dev-rg"
  location            = "eastus"
  subnet_id           = "subnet-id-value"
  vm_size             = "Standard_B2s"
  vm_count            = 2
  admin_username      = "azureuser"
  ssh_public_key      = "ssh-ed25519 AAAAC3NzaC1l..."
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `resource_group_name` | `string` | N/A | Target Azure Resource Group |
| `location` | `string` | N/A | Location region |
| `subnet_id` | `string` | N/A | Subnet ID to place VM NICs |
| `vm_size` | `string` | `"Standard_B2s"` | VM instance size |
| `vm_count` | `number` | `1` | Total VMs to create |
| `admin_username` | `string` | `"azureuser"` | Default admin username |
| `ssh_public_key` | `string` | N/A | Public SSH Key file value |
| `environment` | `string` | N/A | Environment (dev/stage/prod) |

## Outputs

| Name | Description |
|------|-------------|
| `lb_public_ip` | Azure Load Balancer public IP address |
| `vm_private_ips` | VM Private IPs array |
| `vm_public_ips` | VM Public IPs array (dynamic allocations) |
| `vm_principal_ids` | Managed Identity system identities |
