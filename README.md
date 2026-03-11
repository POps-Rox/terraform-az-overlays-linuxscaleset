<!-- BADGES:START -->
[![CI](https://github.com/POps-Rox/tf-az-overlays-linuxscaleset/actions/workflows/ci.yml/badge.svg)](https://github.com/POps-Rox/tf-az-overlays-linuxscaleset/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/POps-Rox/tf-az-overlays-linuxscaleset/pulls)
[![Maintained](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/POps-Rox/tf-az-overlays-linuxscaleset/graphs/commit-activity)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-623CE4.svg?logo=terraform)](https://www.terraform.io)
<!-- BADGES:END -->

# Azure Linux ScaleSet Overlay Terraform Module

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![MIT License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/azurenoops/overlays-front-door/azurerm/)

This Overlay terraform module can create a Azure Linux ScaleSet to be used in a [SCCA compliant Network](https://registry.terraform.io/modules/azurenoops/overlays-hubspoke/azurerm/latest).

## SCCA Compliance

This module can be SCCA compliant and can be used in a SCCA compliant Network. Enable private endpoints and SCCA compliant network rules to make it SCCA compliant.

For more information, please read the [SCCA documentation]("https://www.cisa.gov/secure-cloud-computing-architecture").

## Contributing

If you want to contribute to this repository, feel free to to contribute to our Terraform module.

More details are available in the [CONTRIBUTING.md](./CONTRIBUTING.md#pull-request-process) file.

## Usage

```hcl
module "vmss_linux" {
  source  = "POps-Rox/tf-az-overlays-linux-scaleset/azurerm"
  version = "x.x.x"

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
  vms_size = "Standard_D2d_v5"

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
```
