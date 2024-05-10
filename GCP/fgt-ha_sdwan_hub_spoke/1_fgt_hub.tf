#------------------------------------------------------------------------------------------------------------
# Create VPCs and subnets Fortigate
# - VPC for MGMT and HA interface
# - VPC for Public interface
# - VPC for Private interface  
#------------------------------------------------------------------------------------------------------------
module "hub_vpc" {
  source  = "jmvigueras/ftnt-gcp-modules/gcp//modules/vpc_fgt"
  version = "0.0.2"

  region = local.region
  prefix = "${local.prefix}-hub"

  vpc-sec_cidr = local.hub_cidr
}
#------------------------------------------------------------------------------------------------------------
# Create FGT cluster config
#------------------------------------------------------------------------------------------------------------
module "hub_config" {
  source  = "jmvigueras/ftnt-gcp-modules/gcp//modules/fgt_config"
  version = "0.0.5"

  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)

  subnet_cidrs       = module.hub_vpc.subnet_cidrs
  fgt-active-ni_ips  = module.hub_vpc.fgt-active-ni_ips
  fgt-passive-ni_ips = module.hub_vpc.fgt-passive-ni_ips

  config_fgcp = true

  config_hub = true
  hub        = local.hub

  config_xlb = true
  ilb_ip     = module.hub_vpc.ilb_ip
  elb_ip     = google_compute_address.hub_elb_frontend_pip.address

  vpc-spoke_cidr = [module.hub_vpc.subnet_cidrs["bastion"]]
}
#------------------------------------------------------------------------------------------------------------
# Create FGT cluster instances
#------------------------------------------------------------------------------------------------------------
module "hub" {
  source  = "jmvigueras/ftnt-gcp-modules/gcp//modules/fgt_ha"
  version = "0.0.2"

  prefix = "${local.prefix}-hub"
  region = local.region
  zone1  = local.zone1
  zone2  = local.zone2

  machine        = local.fgt_machine
  rsa-public-key = trimspace(tls_private_key.ssh.public_key_openssh)
  gcp-user_name  = split("@", data.google_client_openid_userinfo.me.email)[0]
  license_type   = local.fgt_license_type
  fgt_version    = local.fgt_version

  subnet_names       = module.hub_vpc.subnet_names
  fgt-active-ni_ips  = module.hub_vpc.fgt-active-ni_ips
  fgt-passive-ni_ips = module.hub_vpc.fgt-passive-ni_ips

  fgt_config_1 = module.hub_config.fgt_config_1
  fgt_config_2 = module.hub_config.fgt_config_2

  fgt_passive = true
}
#------------------------------------------------------------------------------------------------------------
# Create Internal and External Load Balancer
#------------------------------------------------------------------------------------------------------------
# eLB Frontend public IP
resource "google_compute_address" "hub_elb_frontend_pip" {
  name         = "${local.prefix}-hub-elb-frontend-pip"
  region       = local.region
  address_type = "EXTERNAL"
}
# Create iLB and eLB
module "hub_xlb" {
  source  = "./modules/xlb"

  prefix = "${local.prefix}-hub"
  region = local.region
  zone1  = local.zone1
  zone2  = local.zone2

  vpc_names             = module.hub_vpc.vpc_names
  subnet_names          = module.hub_vpc.subnet_names
  ilb_ip                = module.hub_vpc.ilb_ip
  elb_frontend_pip      = google_compute_address.hub_elb_frontend_pip.address
  fgt_active_self_link  = module.hub.fgt_active_self_link
  fgt_passive_self_link = one(module.hub.fgt_passive_self_link)
}