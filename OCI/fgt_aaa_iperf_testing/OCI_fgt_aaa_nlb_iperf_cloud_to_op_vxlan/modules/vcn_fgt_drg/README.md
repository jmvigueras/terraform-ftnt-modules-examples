# Terraform Module: Fortigates VCN

Create a Virtual Cloud Network (VCN) to locate fortigate instaces

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_core_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_internet_gateway) | resource |
| [oci_core_network_security_group.nsg_bastion](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group) | resource |
| [oci_core_network_security_group.nsg_mgmt](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group) | resource |
| [oci_core_network_security_group.nsg_private](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group) | resource |
| [oci_core_network_security_group.nsg_public](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group) | resource |
| [oci_core_network_security_group_security_rule.nsg_bastion_1](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.nsg_sl_mgmt_admin_1](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.nsg_sl_mgmt_admin_2](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.nsg_sl_mgmt_admin_3](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.nsg_sl_mgmt_admin_4](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.nsg_sl_mgmt_ha_1](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.nsg_sl_private_1](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.nsg_sl_public_1](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_route_table.rt_mgmt](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_route_table) | resource |
| [oci_core_route_table.rt_public](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_route_table) | resource |
| [oci_core_security_list.sl_bastion](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_security_list) | resource |
| [oci_core_security_list.sl_mgmt](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_security_list) | resource |
| [oci_core_security_list.sl_private](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_security_list) | resource |
| [oci_core_security_list.sl_public](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_security_list) | resource |
| [oci_core_subnet.subnet_bastion](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_subnet) | resource |
| [oci_core_subnet.subnet_mgmt](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_subnet) | resource |
| [oci_core_subnet.subnet_private](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_subnet) | resource |
| [oci_core_subnet.subnet_public](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_subnet) | resource |
| [oci_core_virtual_network.vcn](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_cidr"></a> [admin\_cidr](#input\_admin\_cidr) | n/a | `string` | `"0.0.0.0/0"` | no |
| <a name="input_admin_port"></a> [admin\_port](#input\_admin\_port) | n/a | `string` | `"8443"` | no |
| <a name="input_availability_domain-a"></a> [availability\_domain-a](#input\_availability\_domain-a) | Choose an Availability Domain (1,2,3) | `string` | `"1"` | no |
| <a name="input_availability_domain-b"></a> [availability\_domain-b](#input\_availability\_domain-b) | n/a | `string` | `"2"` | no |
| <a name="input_bootstrap_vm-a"></a> [bootstrap\_vm-a](#input\_bootstrap\_vm-a) | n/a | `string` | `"./userdata/bootstrap_vm-a.tpl"` | no |
| <a name="input_bootstrap_vm-b"></a> [bootstrap\_vm-b](#input\_bootstrap\_vm-b) | n/a | `string` | `"./userdata/bootstrap_vm-b.tpl"` | no |
| <a name="input_compartment_ocid"></a> [compartment\_ocid](#input\_compartment\_ocid) | n/a | `any` | n/a | yes |
| <a name="input_instance_shape"></a> [instance\_shape](#input\_instance\_shape) | n/a | `string` | `"VM.Standard2.4"` | no |
| <a name="input_license_vm-a"></a> [license\_vm-a](#input\_license\_vm-a) | n/a | `string` | `"./license/FGT-A-license-filename.lic"` | no |
| <a name="input_license_vm-b"></a> [license\_vm-b](#input\_license\_vm-b) | n/a | `string` | `"./license/FGT-B-license-filename.lic"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | AWS resourcers prefix description | `string` | `"terraform"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"eu-frankfurt-1"` | no |
| <a name="input_region_ad_1"></a> [region\_ad\_1](#input\_region\_ad\_1) | n/a | `string` | `"1"` | no |
| <a name="input_region_ad_2"></a> [region\_ad\_2](#input\_region\_ad\_2) | n/a | `string` | `"2"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Resouce Tags | `map(string)` | <pre>{<br>  "owner": "terraform",<br>  "project": "terraform-deploy"<br>}</pre> | no |
| <a name="input_untrust_public_ip_lifetime"></a> [untrust\_public\_ip\_lifetime](#input\_untrust\_public\_ip\_lifetime) | n/a | `string` | `"RESERVED"` | no |
| <a name="input_vcn_cidr"></a> [vcn\_cidr](#input\_vcn\_cidr) | # VCN and SUBNET ADDRESSESS | `string` | `"172.20.0.0/24"` | no |
| <a name="input_vm_image_ocid"></a> [vm\_image\_ocid](#input\_vm\_image\_ocid) | n/a | `string` | `"ocid1.image.oc1..aaaaaaaabu6hszx2yexxqddvekarvsmpdltvp6sqqmrmlgqilpxuxjtqvyla"` | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | n/a | `string` | `"50"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fgt_1_ips"></a> [fgt\_1\_ips](#output\_fgt\_1\_ips) | n/a |
| <a name="output_fgt_1_vnic_ips"></a> [fgt\_1\_vnic\_ips](#output\_fgt\_1\_vnic\_ips) | n/a |
| <a name="output_fgt_2_ips"></a> [fgt\_2\_ips](#output\_fgt\_2\_ips) | n/a |
| <a name="output_fgt_2_vnic_ips"></a> [fgt\_2\_vnic\_ips](#output\_fgt\_2\_vnic\_ips) | n/a |
| <a name="output_fgt_nsg_ids"></a> [fgt\_nsg\_ids](#output\_fgt\_nsg\_ids) | n/a |
| <a name="output_fgt_subnet_cidrs"></a> [fgt\_subnet\_cidrs](#output\_fgt\_subnet\_cidrs) | n/a |
| <a name="output_fgt_subnet_ids"></a> [fgt\_subnet\_ids](#output\_fgt\_subnet\_ids) | n/a |
| <a name="output_fgt_vcn_id"></a> [fgt\_vcn\_id](#output\_fgt\_vcn\_id) | n/a |
<!-- END_TF_DOCS -->