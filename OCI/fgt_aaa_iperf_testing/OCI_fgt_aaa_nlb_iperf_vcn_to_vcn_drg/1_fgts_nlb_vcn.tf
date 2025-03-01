#-----------------------------------------------------------------------
# Deploy FortiGates VCN with NLB
#-----------------------------------------------------------------------
// Create new VNC
module "fgt_vcn" {
  source  = "jmvigueras/ftnt-oci-modules/oci//modules/vcn_fgt"
  version = "0.0.3"

  compartment_ocid = var.compartment_ocid

  region     = var.region
  prefix     = local.prefix
  admin_cidr = local.admin_cidr
  admin_port = local.admin_port

  vcn_cidr = local.vcn_cidr
}
// Create FGTs config
module "fgt_config" {
  source = "./modules/fgt_config"

  for_each = local.fgt_ips

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa_public_key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = random_string.api_key.result

  config_fgsp       = true
  config_auto_scale = true

  fgt_subnet_cidrs = local.fgt_subnet_cidrs
  fgt_ips          = each.value

  fgt_id          = "ad${each.key + 1}-fgt${each.key + 1}-drg"
  fgsp_member_id  = each.key
  fgsp_member_ips = local.fgsp_member_ips

  vcn_spoke_cidrs = local.spokes_cidrs
}
// Create FGT instances
module "fgt" {
  source  = "jmvigueras/ftnt-oci-modules/oci//modules/fgt"
  version = "0.0.3"

  for_each = local.fgt_ips

  compartment_ocid = var.compartment_ocid

  region    = var.region
  region_ad = each.key + 1

  prefix = "${local.prefix}-drg"
  suffix = each.key + 1

  instance_shape = local.fgt_shape
  fgt_image_ids  = local.fgt_image_ids

  fgt_config = module.fgt_config[each.key].fgt_config

  fgt_vcn_id     = module.fgt_vcn.fgt_vcn_id
  fgt_subnet_ids = module.fgt_vcn.fgt_subnet_ids
  fgt_nsg_ids    = module.fgt_vcn.fgt_nsg_ids

  fgt_vnic_ips = each.value
}
// Create Internal NLB
module "nlb" {
  depends_on = [module.fgt]

  source  = "jmvigueras/ftnt-oci-modules/oci//modules/nlb"
  version = "0.0.3"

  compartment_ocid = var.compartment_ocid

  prefix = "${local.prefix}-drg"

  subnet_id = module.fgt_vcn.fgt_subnet_ids["private"]
  nsg_ids   = [module.fgt_vcn.fgt_nsg_ids["private"]]

  load_balance_policy = "FIVE_TUPLE"
  backend_ips         = { for k, v in local.fgt_ips : "fgt${k + 1}" => v["private"] }
}
// Create Route Table to point default to NLB
resource "oci_core_route_table" "rt_to_nlb" {
  compartment_id = var.compartment_ocid
  vcn_id         = module.fgt_vcn.fgt_vcn_id
  display_name   = "${local.prefix}-rt-to-nlb"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = module.nlb.i_nlb_ip_id
  }
}
#-----------------------------------------------------------------------
# Create HUB-SPOKE VCNs topology with DRG
#-----------------------------------------------------------------------
// Create new DRG
module "drg" {
  depends_on = [module.fgt_vcn, module.fgt]

  source  = "jmvigueras/ftnt-oci-modules/oci//modules/drg"
  version = "0.0.3"

  compartment_ocid = var.compartment_ocid
  prefix           = local.prefix

  fgt_vcn_id        = module.fgt_vcn.fgt_vcn_id
  fgt_vcn_rt_drg_id = oci_core_route_table.rt_to_nlb.id
  fgt_subnet_ids    = module.fgt_vcn.fgt_subnet_ids
}
// Create spoke VCN and attached to DRG
module "spoke_vcns" {
  source  = "jmvigueras/ftnt-oci-modules/oci//modules/vcn_spoke_drg"
  version = "0.0.3"

  for_each = { for i, v in local.spokes_cidrs : i => v }

  compartment_ocid = var.compartment_ocid
  prefix           = local.prefix
  sufix            = each.key + 1

  admin_cidr = local.admin_cidr
  vcn_cidr   = each.value
  drg_id     = module.drg.drg_id
  drg_rt_id  = module.drg.drg_rt_ids["pre"]
}








#-----------------------------------------------------------------------
# Necessary variables
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "./ssh-key/${local.prefix}-ssh-key.pem"
  file_permission = "0600"
}
locals {
  authorized_keys = [chomp(tls_private_key.ssh.public_key_openssh)]
}
# Create new random API key to be provisioned in FortiGates.
resource "random_string" "api_key" {
  length  = 30
  special = false
  numeric = true
}
