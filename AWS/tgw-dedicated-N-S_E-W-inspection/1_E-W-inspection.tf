#------------------------------------------------------------------------------
# Create FGT cluster:
# - VPC
# - FGT NI and SG
# - Fortigate config
# - FGT instance
#------------------------------------------------------------------------------
# Create VPC for hub EU
module "ew_fgt_vpc" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vpc"
  version = "0.0.5"

  prefix     = "${local.prefix}-ew"
  admin_cidr = local.admin_cidr
  region     = local.region
  azs        = local.azs

  cidr = local.ew_fgt_vpc_cidr

  public_subnet_names  = local.ew_public_subnet_names
  private_subnet_names = local.ew_private_subnet_names
}
# Create FGT NIs
module "ew_fgt_nis" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/fgt_ni_sg"
  version = "0.0.5"

  prefix = "${local.prefix}-ew"
  azs    = local.azs

  vpc_id      = module.ew_fgt_vpc.vpc_id
  subnet_list = module.ew_fgt_vpc.subnet_list

  fgt_subnet_tags = local.ew_fgt_subnet_tags

  fgt_number_peer_az = local.ew_fgt_number_peer_az
  cluster_type       = local.ew_fgt_cluster_type
}
# Create FGTs config
module "ew_fgt_config" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/fgt_config"
  version = "0.0.5"

  for_each = { for k, v in module.ew_fgt_nis.fgt_ports_config : k => v }

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa_public_key = tls_private_key.ssh.public_key_openssh
  api_key        = random_string.api_key.result

  ports_config = each.value

  config_fgcp       = local.ew_fgt_cluster_type == "fgcp" ? true : false
  config_fgsp       = local.ew_fgt_cluster_type == "fgsp" ? true : false
  config_auto_scale = local.ew_fgt_cluster_type == "fgsp" ? true : false

  fgt_id     = each.key
  ha_members = module.ew_fgt_nis.fgt_ports_config

  config_gwlb           = true
  gwlbe_ip              = lookup(zipmap(keys(module.ew_fgt_nis.fgt_ports_config), values(module.gwlb.gwlbe_ips)), each.key, "")
  gwlb_inspection_cidrs = local.vpc_spokes_cidrs

  static_route_cidrs = [local.ew_fgt_vpc_cidr]
}
# Create FGT for hub EU
module "ew_fgt" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/fgt"
  version = "0.0.5"

  prefix        = "${local.prefix}-fgsp"
  region        = local.region
  instance_type = local.instance_type
  keypair       = trimspace(aws_key_pair.keypair.key_name)

  license_type = local.license_type
  fgt_build    = local.fgt_build

  fgt_ni_list = module.ew_fgt_nis.fgt_ni_list
  fgt_config  = { for k, v in module.ew_fgt_config : k => v.fgt_config }
}
#------------------------------------------------------------------------------
# GWLB
#------------------------------------------------------------------------------
# Create GWLB
module "gwlb" {
  //source  = "jmvigueras/ftnt-aws-modules/aws//modules/gwlb"
  //version = "0.0.5"
  source = "./modules/gwlb"

  prefix     = local.prefix
  subnet_ids = { for k, v in module.ew_fgt_vpc.subnet_ids : k => lookup(v, "gwlb", "") }
  vpc_id     = module.ew_fgt_vpc.vpc_id
  fgt_ips    = compact([for k, v in module.ew_fgt_nis.fgt_ips_map : lookup(v, "port2.private", "")])

  backend_port     = "8008"
  backend_protocol = "HTTP"
  backend_interval = 10

  tags = local.tags
}
# Create GWLB endpoints
module "gwlb_endpoint" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/gwlb_endpoint"
  version = "0.0.5"

  gwlb_service_name = module.gwlb.gwlb_service_name
  subnet_ids        = { for i, v in local.azs : "gwlb-az${i + 1}" => lookup(module.ew_fgt_vpc.subnet_ids["az${i + 1}"], "gwlb", "") }
  vpc_id            = module.ew_fgt_vpc.vpc_id

  tags = local.tags
}
#------------------------------------------------------------------------------
# TGW
#------------------------------------------------------------------------------
# Create TGW Attachment
module "ew_tgw_attachment" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/tgw_attachment"
  version = "0.0.5"

  prefix = "${local.prefix}-ew"

  vpc_id         = module.ew_fgt_vpc.vpc_id
  tgw_id         = module.tgw.tgw_id
  tgw_subnet_ids = [for i, v in local.azs : module.ew_fgt_vpc.subnet_ids["az${i + 1}"]["tgw"]]

  appliance_mode_support = "disable"

  rt_association_id  = module.tgw.rt_post_inspection_id
  rt_propagation_ids = [module.tgw.rt_pre_inspection_id]

  tags = local.tags
}
# Create static route in TGW RouteTable PRE inspection
# - Private range route to E-W fortigates VPC
resource "aws_ec2_transit_gateway_route" "ew_tgw_route" {
  destination_cidr_block         = "172.16.0.0/12"
  transit_gateway_attachment_id  = module.ew_tgw_attachment.id
  transit_gateway_route_table_id = module.tgw.rt_pre_inspection_id
}
#------------------------------------------------------------------------------
# Update VPC routes
#------------------------------------------------------------------------------
# Update private RT route RFC1918 cidrs to FGT NI and TGW
module "ew_fgt_vpc_routes" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vpc_routes"
  version = "0.0.5"

  tgw_id     = module.tgw.tgw_id
  tgw_rt_ids = local.ew_tgw_rt_ids

  gwlbe_id    = module.gwlb_endpoint.gwlb_endpoints["gwlb-az1"]
  gwlb_rt_ids = local.ew_gwlb_rt_ids
}
locals {
  ew_gwlbe_rt_subnet_names = ["tgw"]
  ew_tgw_rt_subnet_names   = ["gwlb"]
  # Create map of RT IDs where add routes pointing to a GWLB Endpoint
  ew_gwlb_rt_ids = {
    for pair in setproduct(local.ew_gwlbe_rt_subnet_names, [for i, az in local.azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.ew_fgt_vpc.rt_ids[pair[1]][pair[0]]
  }
  # Create map of RT IDs where add routes pointing to a TGW ID
  ew_tgw_rt_ids = {
    for pair in setproduct(local.ew_tgw_rt_subnet_names, [for i, az in local.azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.ew_fgt_vpc.rt_ids[pair[1]][pair[0]]
  }
}