# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

locals {
  # Naming locals/constants
  name_prefix = lower(var.name_prefix)
  name_suffix = lower(var.name_suffix)

  resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, module.mod_linux_vmss_rg.*.resource_group_name, [""]), 0)
  location            = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, module.mod_linux_vmss_rg.*.resource_group_location, [""]), 0)

  vmss_name     = coalesce(var.custom_vmss_name, data.popsrox_utils_resource_name.vmss_linux.result)
  nic_name      = coalesce(var.custom_nic_name, data.popsrox_utils_resource_name.nic.result)
  ipconfig_name = coalesce(var.custom_ipconfig_name, data.popsrox_utils_resource_name.ipconfig.result)
  dcr_name      = coalesce(var.custom_dcr_name, format("dcra-%s", azurerm_linux_virtual_machine_scale_set.linux_vmss.name))
}
