# Terraform Module:  OCI linux Instance

Create an OCI linux instance.

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
| [oci_core_instance.vm](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_instance) | resource |
| [oci_core_images.vm_image](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_images) | data source |
| [oci_identity_availability_domains.region_ads](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_availability_domains) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authorized_keys"></a> [authorized\_keys](#input\_authorized\_keys) | SSH RSA public key for KeyPair if not exists | `list(string)` | `null` | no |
| <a name="input_compartment_ocid"></a> [compartment\_ocid](#input\_compartment\_ocid) | n/a | `any` | n/a | yes |
| <a name="input_memory_in_gbs"></a> [memory\_in\_gbs](#input\_memory\_in\_gbs) | n/a | `number` | `2` | no |
| <a name="input_ocpus"></a> [ocpus](#input\_ocpus) | n/a | `number` | `1` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | OCI resourcers description | `string` | `"terraform"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region | `string` | `"eu-frankfurt-1"` | no |
| <a name="input_region_ad"></a> [region\_ad](#input\_region\_ad) | n/a | `string` | `"1"` | no |
| <a name="input_shape"></a> [shape](#input\_shape) | VM | `string` | `"VM.Standard.A1.Flex"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | n/a | `string` | `null` | no |
| <a name="input_sufix"></a> [sufix](#input\_sufix) | n/a | `string` | `"1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Resouce Tags | `map(string)` | <pre>{<br>  "owner": "terraform",<br>  "project": "terraform-deploy"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm"></a> [vm](#output\_vm) | n/a |
<!-- END_TF_DOCS -->