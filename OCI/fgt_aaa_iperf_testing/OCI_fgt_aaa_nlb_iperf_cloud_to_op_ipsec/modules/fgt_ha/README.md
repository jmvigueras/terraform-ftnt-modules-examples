# Terraform Module: Fortigate cluster instances

Create Fortigate HA cluster instances

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
| [oci_core_instance.fgt_1](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_instance) | resource |
| [oci_core_instance.fgt_2](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_instance) | resource |
| [oci_core_private_ip.fgt_1_vnic_private_ip_sec](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_private_ip) | resource |
| [oci_core_private_ip.fgt_1_vnic_public_ip_sec](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_private_ip) | resource |
| [oci_core_public_ip.fgt_1_vnic_public_ip_sec](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_public_ip) | resource |
| [oci_core_route_table.rt_to_fgt](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_route_table) | resource |
| [oci_core_route_table_attachment.rt_to_fgt_attach_bastion](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_route_table_attachment) | resource |
| [oci_core_vnic_attachment.fgt_1_vnic_private](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_vnic_attachment) | resource |
| [oci_core_vnic_attachment.fgt_1_vnic_public](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_vnic_attachment) | resource |
| [oci_core_vnic_attachment.fgt_2_vnic_private](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_vnic_attachment) | resource |
| [oci_core_vnic_attachment.fgt_2_vnic_public](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_vnic_attachment) | resource |
| [oci_core_volume.fgt_1_vol_a](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume) | resource |
| [oci_core_volume.fgt_2_vol_a](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume) | resource |
| [oci_core_volume_attachment.fgt_1_vol_a_attach](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume_attachment) | resource |
| [oci_core_volume_attachment.fgt_2_vol_a_attach](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume_attachment) | resource |
| [oci_identity_availability_domain.ad_1](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_availability_domain) | data source |
| [oci_identity_availability_domain.ad_2](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_availability_domain) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_ocid"></a> [compartment\_ocid](#input\_compartment\_ocid) | OCI compartment ID | `any` | n/a | yes |
| <a name="input_fgt_1_ips"></a> [fgt\_1\_ips](#input\_fgt\_1\_ips) | Fortigate 1 map of IPs of each port | `map(string)` | `null` | no |
| <a name="input_fgt_1_vnic_ips"></a> [fgt\_1\_vnic\_ips](#input\_fgt\_1\_vnic\_ips) | Fortigate 1 instance map of IPs of each network interface | `map(string)` | `null` | no |
| <a name="input_fgt_2_ips"></a> [fgt\_2\_ips](#input\_fgt\_2\_ips) | Fortigate 2 map of IPs of each port | `map(string)` | `null` | no |
| <a name="input_fgt_2_vnic_ips"></a> [fgt\_2\_vnic\_ips](#input\_fgt\_2\_vnic\_ips) | Fortigate 2 instance map of IPs of each network interface | `map(string)` | `null` | no |
| <a name="input_fgt_config_1"></a> [fgt\_config\_1](#input\_fgt\_config\_1) | Fotigate 1 bootstrap config | `string` | `""` | no |
| <a name="input_fgt_config_2"></a> [fgt\_config\_2](#input\_fgt\_config\_2) | Fotigate 1 bootstrap config | `string` | `""` | no |
| <a name="input_fgt_ha_fgsp"></a> [fgt\_ha\_fgsp](#input\_fgt\_ha\_fgsp) | Boolean to define Fortigate cluster as FGSP | `bool` | `false` | no |
| <a name="input_fgt_image_ids"></a> [fgt\_image\_ids](#input\_fgt\_image\_ids) | Fortigate image IDs either BYOL or PAYG | `map(string)` | <pre>{<br>  "byol": "ocid1.image.oc1..aaaaaaaalj3fxkjxnru4i5725rl45iur3ducp5fy5dmulwzjtepathmtxbta",<br>  "payg": "ocid1.image.oc1..aaaaaaaatwwtthsopj6iqfg762xpwnsmsnuzwhpwad7lw6slfjrao2f3bnha"<br>}</pre> | no |
| <a name="input_fgt_ni_0"></a> [fgt\_ni\_0](#input\_fgt\_ni\_0) | Index 0 instace interface type of port | `string` | `"public"` | no |
| <a name="input_fgt_ni_1"></a> [fgt\_ni\_1](#input\_fgt\_ni\_1) | Index 1 instace interface type of port | `string` | `"private"` | no |
| <a name="input_fgt_ni_2"></a> [fgt\_ni\_2](#input\_fgt\_ni\_2) | Index 2 instace interface type of port | `string` | `"mgmt"` | no |
| <a name="input_fgt_ni_3"></a> [fgt\_ni\_3](#input\_fgt\_ni\_3) | Index 3 instace interface type of port | `string` | `"ha"` | no |
| <a name="input_fgt_nsg_ids"></a> [fgt\_nsg\_ids](#input\_fgt\_nsg\_ids) | Map of security groups to assign | `map(string)` | `null` | no |
| <a name="input_fgt_passive"></a> [fgt\_passive](#input\_fgt\_passive) | Booolean to create Fortigate passive instance | `bool` | `false` | no |
| <a name="input_fgt_subnet_ids"></a> [fgt\_subnet\_ids](#input\_fgt\_subnet\_ids) | Fortigate subnets IDs map | `map(string)` | `null` | no |
| <a name="input_fgt_vcn_id"></a> [fgt\_vcn\_id](#input\_fgt\_vcn\_id) | Orace VCN where deploy Fortigate instances | `string` | `null` | no |
| <a name="input_instance_shape"></a> [instance\_shape](#input\_instance\_shape) | Oracle instance types | `string` | `"VM.Standard2.4"` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | Provide the license type for FortiGate-VM Instances, either byol or payg | `string` | `"payg"` | no |
| <a name="input_memory_in_gbs"></a> [memory\_in\_gbs](#input\_memory\_in\_gbs) | OCI instance GBp of RAM memory, used if type of instance is flex | `number` | `16` | no |
| <a name="input_ocpus"></a> [ocpus](#input\_ocpus) | OCI instance number of CPUs, used if type of instance is flex | `number` | `4` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Resources prefix description | `string` | `"terraform"` | no |
| <a name="input_public_ip_lifetime"></a> [public\_ip\_lifetime](#input\_public\_ip\_lifetime) | Type of public IPs | `string` | `"RESERVED"` | no |
| <a name="input_region"></a> [region](#input\_region) | OCI region to deploy fortigate instances | `string` | `"eu-frankfurt-1"` | no |
| <a name="input_region_ad_1"></a> [region\_ad\_1](#input\_region\_ad\_1) | OCI region Availability Domain 1 | `string` | `"1"` | no |
| <a name="input_region_ad_2"></a> [region\_ad\_2](#input\_region\_ad\_2) | OCI region Availability Domain 2 | `string` | `"2"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Attribute for tag Enviroment | `map(any)` | <pre>{<br>  "project": "terraform"<br>}</pre> | no |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | OCI Tenancy ID | `string` | `""` | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | Default secondary disk size | `string` | `"50"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fgt_1_id"></a> [fgt\_1\_id](#output\_fgt\_1\_id) | Fortigate 1 instance id |
| <a name="output_fgt_1_public_ip_mgmt"></a> [fgt\_1\_public\_ip\_mgmt](#output\_fgt\_1\_public\_ip\_mgmt) | Fortigate 1 public IP management interface |
| <a name="output_fgt_1_public_ip_public"></a> [fgt\_1\_public\_ip\_public](#output\_fgt\_1\_public\_ip\_public) | Fortigate 1 public IP public interface |
| <a name="output_fgt_2_id"></a> [fgt\_2\_id](#output\_fgt\_2\_id) | Fortigate 2 instance id |
| <a name="output_fgt_2_public_ip_mgmt"></a> [fgt\_2\_public\_ip\_mgmt](#output\_fgt\_2\_public\_ip\_mgmt) | Fortigate 2 public IP management interface |
| <a name="output_fgt_vcn_rt_to_fgt_id"></a> [fgt\_vcn\_rt\_to\_fgt\_id](#output\_fgt\_vcn\_rt\_to\_fgt\_id) | Route table ID created for bastion subnet in Fortigate VCN |
<!-- END_TF_DOCS -->