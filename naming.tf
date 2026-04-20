# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

data "popsrox_utils_resource_name" "vmss_linux" {
  name          = var.workload_name
  resource_type = "azurerm_linux_virtual_machine_scale_set"
  prefixes      = [var.org_name, module.mod_azure_region_lookup.location_short]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "vmss"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "popsrox_utils_resource_name" "nic" {
  name          = var.workload_name
  resource_type = "azurerm_network_interface"
  prefixes      = [var.org_name, module.mod_azure_region_lookup.location_short]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "nic"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "popsrox_utils_resource_name" "ipconfig" {
  name          = var.workload_name
  resource_type = "azurerm_resource_group"
  prefixes      = [var.org_name, module.mod_azure_region_lookup.location_short]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "ipconfig" : ""])
  use_slug      = false
  clean_input   = true
  separator     = "-"
}


