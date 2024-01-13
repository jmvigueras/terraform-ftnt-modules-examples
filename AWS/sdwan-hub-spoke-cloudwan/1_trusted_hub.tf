#------------------------------------------------------------------------------
# Create FGT cluster EU
# - VPC
# - FGT NI and SG
# - FGT instance
#------------------------------------------------------------------------------
# Create VPC for hub EU
module "eu_hub_vpc" {
  source = "git::github.com/jmvigueras/terraform-ftnt-aws-modules//vpc?ref=v0.0.1"

  prefix     = "${local.prefix}-eu-hub"
  admin_cidr = local.admin_cidr
  region     = local.eu_region
  azs        = local.eu_azs

  cidr = local.eu_hub_vpc_cidr

  public_subnet_names  = local.eu_hub_fgt_vpc_public_subnet_names
  private_subnet_names = local.eu_hub_fgt_vpc_private_subnet_names
}
# Create FGT NIs
module "eu_hub_nis" {
  source = "git::github.com/jmvigueras/terraform-ftnt-aws-modules//fgt_ni_sg?ref=v0.0.1"

  prefix             = "${local.prefix}-eu-hub"
  azs                = local.eu_azs
  vpc_id             = module.eu_hub_vpc.vpc_id
  subnet_list        = module.eu_hub_vpc.subnet_list
  fgt_subnet_tags    = local.eu_hub_fgt_subnet_tags
  fgt_number_peer_az = local.eu_hub_number_peer_az
  cluster_type       = local.eu_hub_cluster_type
}
module "eu_hub_config" {
  for_each = { for k, v in module.eu_hub_nis.fgt_ports_config : k => v }
  source   = "git::github.com/jmvigueras/terraform-ftnt-aws-modules//fgt_config?ref=v0.0.1"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa_public_key = tls_private_key.ssh.public_key_openssh
  api_key        = random_string.api_key.result

  ports_config = each.value

  config_fgcp       = local.eu_hub_cluster_type == "fgcp" ? true : false
  config_fgsp       = local.eu_hub_cluster_type == "fgsp" ? true : false
  config_auto_scale = local.eu_hub_cluster_type == "fgsp" ? true : false

  fgt_id     = each.key
  ha_members = module.eu_hub_nis.fgt_ports_config

  config_hub = true
  hub        = local.eu_hub

  static_route_cidrs = [local.eu_hub_cidr]
}
# Create FGT for hub EU
module "eu_hub" {
  source = "git::github.com/jmvigueras/terraform-ftnt-aws-modules//fgt?ref=v0.0.1"

  prefix        = "${local.prefix}-eu-hub"
  region        = local.eu_region
  instance_type = local.instance_type
  keypair       = aws_key_pair.eu_keypair.key_name

  license_type = local.license_type
  fgt_build    = local.fgt_build

  fgt_ni_list = module.eu_hub_nis.fgt_ni_list
  fgt_config  = { for k, v in module.eu_hub_config : k => v.fgt_config }
}
# Update private RT route RFC1918 cidrs to FGT NI and Core Network
module "eu_hub_vpc_routes" {
  source = "git::github.com/jmvigueras/terraform-ftnt-aws-modules//vpc_routes?ref=v0.0.1"

  ni_id     = module.eu_hub_nis.fgt_ids_map["az1.fgt1"]["port2.private"]
  ni_rt_ids = local.eu_hub_ni_rt_ids

  core_network_arn    = local.core_network_arn
  core_network_rt_ids = local.eu_hub_core_net_rt_ids
}
# Crate test VM in bastion subnet
module "eu_hub_vm" {
  source = "git::github.com/jmvigueras/terraform-ftnt-aws-modules//vm?ref=v0.0.1"

  prefix          = "${local.prefix}-eu-hub"
  keypair         = aws_key_pair.eu_keypair.key_name
  subnet_id       = module.eu_hub_vpc.subnet_ids["az1"]["bastion"]
  subnet_cidr     = module.eu_hub_vpc.subnet_cidrs["az1"]["bastion"]
  security_groups = [module.eu_hub_vpc.sg_ids["default"]]
}

# Create VPC Core Net attachament
resource "aws_networkmanager_vpc_attachment" "eu_hub_vpc_core_net_attachment" {
  subnet_arns     = [for i, az in local.eu_azs : module.eu_hub_vpc.subnet_arns["az${i + 1}"]["corenet"]]
  core_network_id = local.core_network_id
  vpc_arn         = module.eu_hub_vpc.vpc_arn

  tags = {
    segment = "Trusted"
  }
}


