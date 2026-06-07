# Azure Network Module

This module sets up the base resource group, network layout, subnet maps, NSG, and ACR in Azure.

## Features
- Dedicated Azure Resource Group.
- VNet with customizable CIDR spaces.
- Subnets using `for_each` mapping.
- NSG rules configured to allow HTTP (80), HTTPS (443), SSH (22), and Spring Boot (8080) traffic.
- Azure Container Registry (ACR) standard registry for docker containers.

## Example Usage

```hcl
module "azure_network" {
  source              = "../../modules/azure-network"
  environment         = "dev"
  resource_group_name = "bankpro-dev-rg"
  location            = "eastus"
  vnet_cidr           = ["10.1.0.0/16"]

  subnets = {
    web = { address_prefixes = ["10.1.1.0/24"] }
    app = { address_prefixes = ["10.1.2.0/24"] }
  }

  create_acr = true
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `resource_group_name` | `string` | N/A | Resource Group Name |
| `location` | `string` | `"eastus"` | Azure region location |
| `vnet_cidr` | `list(string)` | `["10.1.0.0/16"]` | IP Space of the VNet |
| `subnets` | `map(object)` | N/A | Map of subnets to create |
| `environment` | `string` | N/A | Environment name (dev/stage/prod) |
| `create_acr` | `bool` | `true` | Provision Container Registry |
| `acr_sku` | `string` | `"Standard"` | Azure Registry pricing tier SKU |

## Outputs

| Name | Description |
|------|-------------|
| `resource_group_name` | Managed Resource Group name |
| `vnet_id` | VNet Resource ID |
| `subnet_ids` | Subnet ID array |
| `acr_login_server` | ACR Endpoint URL |
| `acr_admin_username` | Registry Username |
| `acr_admin_password` | Registry Password (Sensitive) |
