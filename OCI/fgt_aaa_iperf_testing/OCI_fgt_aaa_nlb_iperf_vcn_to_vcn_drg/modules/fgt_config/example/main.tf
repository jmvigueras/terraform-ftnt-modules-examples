module "fgt_config" {
  source = "../"

  for_each = local.fgt_ips

  admin_cidr     = local.admin_cidr
  admin_port     = var.admin_port
  rsa_public_key = tls_private_key.ssh.public_key_openssh
  api_key        = random_string.api_key.result

  fgt_subnet_cidrs = local.fgt_subnet_cidrs
  fgt_ips          = each.value

  config_auto_scale = true
  config_fgsp     = true
  fgsp_member_id  = each.key
  fgsp_member_ips = local.fgsp_member_ips

  config_vxlan = true
  vxlan_peers = local.hub1_peer_vxlan[each.key]
}

/*
#---------------------------------------------------------------------------------
# Create FGT cluster HUB1
# - FGSP
# - TGW attachment connect
# - vxlan to HUB2
#---------------------------------------------------------------------------------
module "fgt-config_hub1" {
  source = "../"

  admin_cidr     = local.admin_cidr
  admin_port     = var.admin_port
  rsa_public_key = tls_private_key.ssh.public_key_openssh
  api_key        = random_string.api_key.result

  fgt_subnet_cidrs = local.fgt_subnet_cidrs
  fgt_ips          = local.fgt_ips

  config_fgsp    = local.hub1_cluster_type == "fgsp" ? true : false
  config_hub     = true
  config_vxlan   = true
  hub            = local.hub1
  hub-peer_vxlan = local.hub1_peer_vxlan
}
#---------------------------------------------------------------------------------
# Create FGT cluster HUB2
# - FGCP
# - vxlan to HUB1
#---------------------------------------------------------------------------------
module "fgt-config_hub2" {
  source = "../"

  admin_cidr     = local.admin_cidr
  admin_port     = var.admin_port
  rsa_public_key = tls_private_key.ssh.public_key_openssh
  api_key        = random_string.api_key.result

  fgt_subnet_cidrs = local.fgt_subnet_cidrs
  fgt_ips          = local.fgt_ips

  config_fgsp    = local.hub2_cluster_type == "fgsp" ? true : false
  config_hub     = true
  config_vxlan   = true
  hub            = local.hub2
  hub-peer_vxlan = local.hub2_peer_vxlan
}
#---------------------------------------------------------------------------------
# Create FGT cluster spoke
# - FGCP
#---------------------------------------------------------------------------------
module "fgt-config_spoke" {
  source = "../"

  admin_cidr     = local.admin_cidr
  admin_port     = var.admin_port
  rsa_public_key = tls_private_key.ssh.public_key_openssh
  api_key        = random_string.api_key.result

  fgt_subnet_cidrs = local.fgt_subnet_cidrs
  fgt_ips          = local.fgt_ips

  config_fgsp  = true
  config_spoke = true

  hubs  = local.hubs
  spoke = local.spoke
}
*/









#-----------------------------------------------------------------------
# Necessary variables

data "http" "my-public-ip" {
  url = "http://ifconfig.me/ip"
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "./ssh-key/${var.prefix}-ssh-key.pem"
  file_permission = "0600"
}

# Create new random API key to be provisioned in FortiGates.
resource "random_string" "api_key" {
  length  = 30
  special = false
  numeric = true
}

# Create new random API key to be provisioned in FortiGates.
resource "random_string" "vpn_psk" {
  length  = 30
  special = false
  numeric = true
}
