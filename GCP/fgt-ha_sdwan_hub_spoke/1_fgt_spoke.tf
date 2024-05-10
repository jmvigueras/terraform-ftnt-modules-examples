#------------------------------------------------------------------------------------------------------------
# Create VPCs and subnets Fortigate
#------------------------------------------------------------------------------------------------------------
module "spoke_vpc" {
  source = "./modules/vpc-fgt"

  for_each = { for i, k in local.sdwan_spokes : "spoke${i + 1}" => k }

  region = local.region
  prefix = "${local.prefix}-${each.key}"

  vpc-sec_cidr = each.value["cidr"]
}
#------------------------------------------------------------------------------------------------------------
# Create FGT cluster config
#------------------------------------------------------------------------------------------------------------
module "spoke_config" {
  source = "./modules/fgt-config"

  for_each = { for i, k in local.sdwan_spokes : "spoke${i + 1}" => k }

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = trimspace(random_string.api_key.result)

  subnet_cidrs = module.spoke_vpc[each.key].subnet_cidrs
  fgt_ni_ips   = module.spoke_vpc[each.key].fgt-active-ni_ips

  config_spoke = true
  spoke        = each.value
  hubs         = local.hubs

  license_type = local.fgt_license_type

  vpc-spoke_cidr = [module.spoke_vpc[each.key].subnet_cidrs["bastion"], local.hub_cidr]
}
#------------------------------------------------------------------------------------------------------------
# Create FGT cluster instances
#------------------------------------------------------------------------------------------------------------
module "spoke_fgt" {
  source = "./modules/fgt"

  for_each = { for i, k in local.sdwan_spokes : "spoke${i + 1}" => k }

  region = local.region
  prefix = "${local.prefix}-spoke-${each.key}"
  zone1  = local.zone1

  machine        = local.fgt_machine
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  gcp-user_name  = split("@", data.google_client_openid_userinfo.me.email)[0]
  license_type   = local.fgt_license_type
  fgt_version    = local.fgt_version

  subnet_names = module.spoke_vpc[each.key].subnet_names
  fgt-ni_ips   = module.spoke_vpc[each.key].fgt-active-ni_ips

  fgt_config = module.spoke_config[each.key].fgt_config
}