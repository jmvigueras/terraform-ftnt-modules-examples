#-----------------------------------------------------------------------
# Deploy FortiGates OP AP
#-----------------------------------------------------------------------
// Create new Fortigate VNC
module "hub_op_vcn" {
  source = "./modules/vcn_fgt_drg"

  compartment_ocid = var.compartment_ocid

  region     = var.region
  prefix     = "${local.prefix}-ipsec-op"
  admin_cidr = local.admin_cidr
  admin_port = local.admin_port

  vcn_cidr = local.hub_op_vcn_cidr

  drg_id    = module.drg.drg_id
  drg_rt_id = module.drg.drg_rt_ids["pre"]
}
// Create FGT config
module "hub_op_config" {
  source = "./modules/fgt_ha_config"

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa_public_key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = random_string.api_key.result

  license_type = local.license_type

  fgt_id           = "fgt-op-ipsec"
  fgt_subnet_cidrs = module.hub_op_vcn.fgt_subnet_cidrs
  fgt_1_ips        = module.hub_op_vcn.fgt_1_ips
  fgt_2_ips        = module.hub_op_vcn.fgt_2_ips

  bgp_network = local.hub_op_cidr

  config_fgcp = true

  config_s2s = true
  s2s_peers  = local.hub_op_s2s_peers

  vcn_spoke_cidrs = [module.hub_op_vcn.fgt_subnet_cidrs["bastion"], local.hub_oci_vcn_cidr]

  config_extra_fgt_1 = templatefile("./templates/fgt_cpu_affinity.conf", { "port" = "port3" })
  config_extra_fgt_2 = templatefile("./templates/fgt_cpu_affinity.conf", { "port" = "port3" })
}
// Create FGT instances
module "hub_op" {
  source = "./modules/fgt_ha"

  compartment_ocid = var.compartment_ocid

  region = var.region
  prefix = "${local.prefix}-ipsec-op"

  instance_shape = local.hub_op_shape
  fgt_image_ids  = local.hub_op_image_ids
  ocpus          = local.hub_op_ocpu
  memory_in_gbs  = local.hub_op_memory

  license_type = local.license_type
  fgt_config_1 = module.hub_op_config.fgt_config_1
  fgt_config_2 = module.hub_op_config.fgt_config_2

  fgt_vcn_id     = module.hub_op_vcn.fgt_vcn_id
  fgt_subnet_ids = module.hub_op_vcn.fgt_subnet_ids
  fgt_nsg_ids    = module.hub_op_vcn.fgt_nsg_ids
  fgt_1_ips      = module.hub_op_vcn.fgt_1_ips
  fgt_2_ips      = module.hub_op_vcn.fgt_2_ips
  fgt_1_vnic_ips = module.hub_op_vcn.fgt_1_vnic_ips
  fgt_2_vnic_ips = module.hub_op_vcn.fgt_2_vnic_ips

  igw_id = module.hub_op_vcn.igw_id
}
// Create FGT VCN attachment to DRG
resource "oci_core_drg_attachment" "hub_op_drg_attach" {
  drg_id             = module.drg.drg_id
  display_name       = "${local.prefix}-drg-attach-hub-op"
  drg_route_table_id = module.drg.drg_rt_ids["pre"]

  network_details {
    id             = module.hub_op_vcn.fgt_vcn_id
    type           = "VCN"
    route_table_id = module.hub_op.fgt_vcn_rt_to_fgt_id
  }
}