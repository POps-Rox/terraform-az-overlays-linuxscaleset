module "vmss_linux" {
  #source  = "github.com/POps-Rox/terraform-az-overlays-linuxscaleset"
  #version = "x.x.x"
  source = "../.."

  # By default, this module will create a resource group and 
  # provide a name for an existing resource group. If you wish 
  # to use an existing resource group, change the option 
  # to "create_linux_vmss_resource_group = false." The location of the group 
  # will remain the same if you use the current resource.
  create_linux_vmss_resource_group = true
  location                         = module.mod_azure_region_lookup.location_cli
  environment                      = "public"
  deploy_environment               = "dev"
  org_name                         = "anoa"
  workload_name                    = "vmss"

  # The following variables are used for admin access to the VMs.
  admin_username = "vmss_admin"
  admin_password = "P@ssw0rd1234"

  # The following variables are used for sizing the VMs.
  vms_size = "Standard_D2S_v3"

  # The following variables are used for the VM subnet.
  subnet_id = azurerm_subnet.hub1-subnets.id

  # The following variables are used for the VM image.
  source_image_reference = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # 
  azure_monitor_data_collection_rule_id = azurerm_monitor_data_collection_rule.hub1-dcr.id

  # Tags
  add_tags = {
    example = "basic"
  }
}

