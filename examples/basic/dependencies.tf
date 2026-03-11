
# Azure Region Lookup
module "mod_azure_region_lookup" {
  source  = "github.com/POps-Rox/tf-az-overlays-azregionslookup"
  version = "~> 1.0.0"

  azure_region = "eastus"
}

# Resource Groups
resource "azurerm_resource_group" "rg" {
  name     = "rg-hub-01"
  location = module.mod_azure_region_lookup.location_cli
}

resource "azurerm_virtual_network" "hub1" {
  name                = "vnet-hub-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.100.0/26"]
}

resource "azurerm_subnet" "hub1-subnets" {
  name                 = "snet-vnet-hub-01"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub1.name
  address_prefixes     = ["10.0.100.0/27"]
}

resource "azurerm_log_analytics_workspace" "hub1" {
  name                = "log-hub-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_data_collection_rule" "hub1-dcr" {
  name                = "dcr-hub-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.hub1.id
      name                  = "default-workspace"
    }
    azure_monitor_metrics {
      name = "default-azure-monitor-metrics"
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["default-azure-monitor-metrics"]
  }

  depends_on = [azurerm_log_analytics_workspace.hub1]
}
