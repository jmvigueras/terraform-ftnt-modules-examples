#------------------------------------------------------------------------------
# Create Spokes VPC
# - VPC
# - TGW attachment
# - Update routes
# - Create test VMs 
#------------------------------------------------------------------------------
# Create VPC for hub EU
module "vpc_spokes" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vpc"
  version = "0.0.5"

  for_each = { for i, v in local.vpc_spokes_cidrs : "vpc${i + 1}" => v }

  prefix     = "${local.prefix}-spoke-${each.key}"
  admin_cidr = local.admin_cidr
  region     = local.region
  azs        = local.azs

  cidr = each.value

  public_subnet_names  = local.vpc_spokes_public_subnet_names
  private_subnet_names = local.vpc_spokes_private_subnet_names
}
# Create TGW Attachment
module "vpc_spokes_tgw_attachment" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/tgw_attachment"
  version = "0.0.5"

  for_each = { for i, v in local.vpc_spokes_cidrs : "vpc${i + 1}" => v }

  prefix = "${local.prefix}-spoke-${each.key}"

  vpc_id         = module.vpc_spokes[each.key].vpc_id
  tgw_id         = module.tgw.tgw_id
  tgw_subnet_ids = [for i, v in local.azs : module.vpc_spokes[each.key].subnet_ids["az${i + 1}"]["tgw"]]

  rt_association_id  = module.tgw.rt_pre_inspection_id
  rt_propagation_ids = [module.tgw.rt_post_inspection_id]

  tags = local.tags
}
# Update private RT route RFC1918 cidrs to GWLBe
module "vpc_spokes_routes" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vpc_routes"
  version = "0.0.5"

  for_each = { for i, v in local.vpc_spokes_cidrs : "vpc${i + 1}" => v }

  tgw_id     = module.tgw.tgw_id
  tgw_rt_ids = local.service_tgw_rt_ids[each.key]
}
locals {
  service_tgw_rt_subnet_names = ["vm"]
  # Create map of RT IDs where add routes pointing to a TGW ID
  service_tgw_rt_ids = {
    for i, v in local.vpc_spokes_cidrs : "vpc${i + 1}" => {
      for pair in setproduct(local.service_tgw_rt_subnet_names, [for i, az in local.azs : "az${i + 1}"]) :
      "${pair[0]}-${pair[1]}" => module.vpc_spokes["vpc${i + 1}"].rt_ids[pair[1]][pair[0]]
    }
  }
}
# Create VM
module "vpc_spokes_vm" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vm"
  version = "0.0.5"

  for_each = { for i, v in local.vpc_spokes_cidrs : "vpc${i + 1}" => v }

  prefix          = "${local.prefix}-spoke"
  suffix          = each.key
  keypair         = trimspace(aws_key_pair.keypair.key_name)
  subnet_id       = module.vpc_spokes[each.key].subnet_ids["az1"]["vm"]
  subnet_cidr     = module.vpc_spokes[each.key].subnet_cidrs["az1"]["vm"]
  security_groups = [module.vpc_spokes[each.key].sg_ids["default"]]
}