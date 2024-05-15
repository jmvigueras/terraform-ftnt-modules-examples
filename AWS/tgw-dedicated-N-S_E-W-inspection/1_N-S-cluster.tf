#------------------------------------------------------------------------------
# Create FGT cluster:
# - VPC
# - FGT NI and SG
# - Fortigate config
# - FGT instance
#------------------------------------------------------------------------------
# Create VPC for hub EU
module "ns_fgt_vpc" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vpc"
  version = "0.0.5"

  prefix     = "${local.prefix}-ns"
  admin_cidr = local.admin_cidr
  region     = local.region
  azs        = local.azs

  cidr = local.ns_fgt_vpc_cidr

  public_subnet_names  = local.ns_public_subnet_names
  private_subnet_names = local.ns_private_subnet_names
}
# Create FGT NIs
module "ns_fgt_nis" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/fgt_ni_sg"
  version = "0.0.5"

  prefix = "${local.prefix}-ns"
  azs    = local.azs

  vpc_id      = module.ns_fgt_vpc.vpc_id
  subnet_list = module.ns_fgt_vpc.subnet_list

  fgt_subnet_tags = local.ns_fgt_subnet_tags

  fgt_number_peer_az = local.ns_fgt_number_peer_az
  cluster_type       = local.ns_fgt_cluster_type
}
# Create FGTs config
module "ns_fgt_config" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/fgt_config"
  version = "0.0.5"

  for_each = { for k, v in module.ns_fgt_nis.fgt_ports_config : k => v }

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa_public_key = tls_private_key.ssh.public_key_openssh
  api_key        = random_string.api_key.result

  ports_config = each.value

  config_fgcp       = local.ns_fgt_cluster_type == "fgcp" ? true : false
  config_fgsp       = local.ns_fgt_cluster_type == "fgsp" ? true : false
  config_auto_scale = local.ns_fgt_cluster_type == "fgsp" ? true : false

  fgt_id     = each.key
  ha_members = module.ns_fgt_nis.fgt_ports_config

  static_route_cidrs = local.vpc_spokes_cidrs //necessary routes to stablish BGP peerings and bastion connection
}
# Create FGT for hub EU
module "ns_fgt" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/fgt"
  version = "0.0.5"

  prefix        = "${local.prefix}-ns"
  region        = local.region
  instance_type = local.instance_type
  keypair       = trimspace(aws_key_pair.keypair.key_name)

  license_type = local.license_type
  fgt_build    = local.fgt_build

  fgt_ni_list = module.ns_fgt_nis.fgt_ni_list
  fgt_config  = { for k, v in module.ns_fgt_config : k => v.fgt_config }
}
#------------------------------------------------------------------------------
# TGW
#------------------------------------------------------------------------------
# Create TGW
module "tgw" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/tgw"
  version = "0.0.5"

  prefix = local.prefix

  tgw_cidr    = local.tgw_cidr
  tgw_bgp_asn = local.tgw_bgp_asn
}
# Create TGW Attachment
module "ns_tgw_attachment" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/tgw_attachment"
  version = "0.0.5"

  prefix = "${local.prefix}-ns"

  vpc_id         = module.ns_fgt_vpc.vpc_id
  tgw_id         = module.tgw.tgw_id
  tgw_subnet_ids = [for i, v in local.azs : module.ns_fgt_vpc.subnet_ids["az${i + 1}"]["tgw"]]

  appliance_mode_support = "enable"

  rt_association_id  = module.tgw.rt_post_inspection_id
  rt_propagation_ids = [module.tgw.rt_pre_inspection_id]

  tags = local.tags
}
# Create static route in TGW RouteTable PRE inspection
# - Default route to N-S fortigates VPC
resource "aws_ec2_transit_gateway_route" "ns_tgw_route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.ns_tgw_attachment.id
  transit_gateway_route_table_id = module.tgw.rt_pre_inspection_id
}
#------------------------------------------------------------------------------
# Update VPC routes
#------------------------------------------------------------------------------
# Update private RT route RFC1918 cidrs to FGT NI and TGW
module "ns_fgt_vpc_routes" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vpc_routes"
  version = "0.0.7"

  tgw_id     = module.tgw.tgw_id
  tgw_rt_ids = local.ns_tgw_rt_ids

  ni_id     = module.ns_fgt_nis.fgt_ids_map["az1.fgt1"]["port2.private"]
  ni_rt_ids = local.ns_ni_rt_ids
}
locals {
  ns_ni_rt_subnet_names  = ["tgw"]
  ns_tgw_rt_subnet_names = ["private"]
  # Create map of RT IDs where add routes pointing to a FGT NI
  ns_ni_rt_ids = {
    for pair in setproduct(local.ns_ni_rt_subnet_names, [for i, az in local.azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.ns_fgt_vpc.rt_ids[pair[1]][pair[0]]
  }
  # Create map of RT IDs where add routes pointing to a TGW ID
  ns_tgw_rt_ids = {
    for pair in setproduct(local.ns_tgw_rt_subnet_names, [for i, az in local.azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.ns_fgt_vpc.rt_ids[pair[1]][pair[0]]
  }
}