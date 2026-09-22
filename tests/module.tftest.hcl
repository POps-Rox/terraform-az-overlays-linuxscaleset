mock_provider "azurerm" {}
mock_provider "popsrox" {}

variables {
  location      = "eastus2"
  environment   = "public"
  org_name      = "anoa"
  workload_name = "vmss"

  admin_username = "vmss_admin"
  admin_password = "P@ssw0rd1234!"
  vms_size       = "Standard_D2s_v3"
  subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

override_module {
  target = module.mod_azure_region_lookup
  outputs = {
    location_cli   = "eastus2"
    location_short = "eus2"
  }
}

override_module {
  target = module.mod_linux_vmss_rg
  outputs = {
    resource_group_name     = "rg-generated"
    resource_group_location = "eastus2"
  }
}

override_data {
  target = data.popsrox_resource_name.vmss_linux
  values = {
    result = "vmss-generated"
  }
}

override_data {
  target = data.popsrox_resource_name.nic
  values = {
    result = "nic-generated"
  }
}

override_data {
  target = data.popsrox_resource_name.ipconfig
  values = {
    result = "ipconfig-generated"
  }
}

run "custom_names_tags_location_and_counts_enabled" {
  command = plan

  variables {
    custom_vmss_name     = "vmss-custom"
    custom_nic_name      = "nic-custom"
    custom_ipconfig_name = "ipconfig-custom"
    custom_dcr_name      = "dcr-custom"

    instances_count                       = 3
    azure_monitor_agent_enabled           = true
    azure_monitor_data_collection_rule_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Insights/dataCollectionRules/dcr"
    enable_resource_locks                 = true

    add_tags = {
      core  = "override-core"
      owner = "platform"
    }
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.linux_vmss.name == "vmss-custom"
    error_message = "custom_vmss_name must override the generated VMSS name."
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.linux_vmss.network_interface[0].name == "nic-custom" && azurerm_linux_virtual_machine_scale_set.linux_vmss.network_interface[0].ip_configuration[0].name == "ipconfig-custom"
    error_message = "custom NIC and IP configuration names must override generated names."
  }

  assert {
    condition     = azurerm_monitor_data_collection_rule_association.dcr[0].name == "dcr-custom"
    error_message = "custom_dcr_name must override the generated DCR association name."
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.linux_vmss.location == "eastus2"
    error_message = "VMSS location must pass through the selected resource group location."
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.linux_vmss.instances == 3
    error_message = "instances_count must set the VMSS instances argument."
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.linux_vmss.tags["env"] == "public" && azurerm_linux_virtual_machine_scale_set.linux_vmss.tags["core"] == "override-core" && azurerm_linux_virtual_machine_scale_set.linux_vmss.tags["owner"] == "platform"
    error_message = "VMSS tags must merge default tags with add_tags, allowing add_tags to override matching keys."
  }

  assert {
    condition     = length(azurerm_virtual_machine_scale_set_extension.azure_monitor_agent) == 1 && length(azurerm_monitor_data_collection_rule_association.dcr) == 1 && length(azurerm_management_lock.vmss_level_lock) == 1
    error_message = "Azure Monitor resources and VMSS lock must be created when their enable flags are true."
  }
}

run "empty_custom_names_fall_through_and_counts_disabled" {
  command = plan

  variables {
    custom_vmss_name     = ""
    custom_nic_name      = ""
    custom_ipconfig_name = ""
    custom_dcr_name      = ""

    azure_monitor_agent_enabled = false
    enable_resource_locks       = false
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.linux_vmss.name == "vmss-generated"
    error_message = "An empty custom_vmss_name must fall through to the generated VMSS name."
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.linux_vmss.network_interface[0].name == "nic-generated" && azurerm_linux_virtual_machine_scale_set.linux_vmss.network_interface[0].ip_configuration[0].name == "ipconfig-generated"
    error_message = "Empty custom NIC and IP configuration names must fall through to generated names."
  }

  assert {
    condition     = length(azurerm_virtual_machine_scale_set_extension.azure_monitor_agent) == 0 && length(azurerm_monitor_data_collection_rule_association.dcr) == 0 && length(azurerm_management_lock.vmss_level_lock) == 0
    error_message = "Azure Monitor resources and VMSS lock must not be created when their enable flags are false."
  }
}

run "automatic_upgrade_and_data_disk_mapping" {
  command = plan

  variables {
    upgrade_mode                = "Automatic"
    automatic_os_upgrade        = true
    disable_automatic_rollback  = true
    azure_monitor_agent_enabled = false
    data_disks = [{
      name                 = "data0"
      lun                  = 0
      disk_size_gb         = 64
      disk_iops_read_write = 500
      disk_mbps_read_write = 100
    }]
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.linux_vmss.automatic_os_upgrade_policy[0].automatic_os_upgrade_enabled == true && azurerm_linux_virtual_machine_scale_set.linux_vmss.automatic_os_upgrade_policy[0].automatic_rollback_enabled == false
    error_message = "VMSS automatic OS upgrade policy must map legacy module inputs to azurerm 5.x arguments."
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.linux_vmss.data_disk[0].disk_iops_read_write == 500 && azurerm_linux_virtual_machine_scale_set.linux_vmss.data_disk[0].disk_mbps_read_write == 100
    error_message = "Data disk throughput inputs must map to azurerm 5.x disk_iops_read_write and disk_mbps_read_write arguments."
  }
}
