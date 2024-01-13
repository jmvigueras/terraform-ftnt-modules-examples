#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  prefix = "cloudwan"

  tags = {
    Project = "ftnt_modules_aws"
  }

  eu_region = "eu-west-2"
  eu_azs    = ["eu-west-2a", "eu-west-2b"]

  admin_port = "8443"
  admin_cidr = "${chomp(data.http.my-public-ip.response_body)}/32"
  //admin_cidr    = "0.0.0.0/0"
  instance_type = "c6i.large"
  fgt_build     = "build1575"
  license_type  = "payg"

  route53_zone_name = "fortidemoscloud.com"

  #-----------------------------------------------------------------------------------------------------
  # Cloud WAN - Core Network
  #-----------------------------------------------------------------------------------------------------
  core_network_id  = "core-network-0ccbe4c701d0b93df"
  core_network_arn = "arn:aws:networkmanager::042579265884:core-network/core-network-0ccbe4c701d0b93df"

  #-----------------------------------------------------------------------------------------------------
  # EU - EMEA HUB
  #-----------------------------------------------------------------------------------------------------
  # fgt_subnet_tags -> add tags to FGT subnets (port1, port2, public, private ...)
  eu_hub_fgt_subnet_tags = {
    "port1.public"  = "net-public"
    "port2.private" = "net-private"
    "port3.mgmt"    = "net-mgmt"
  }

  # General variables 
  eu_hub_number_peer_az = 1
  eu_hub_cluster_type   = "fgcp"
  eu_hub_vpc_cidr       = "10.1.0.0/24"

  # VPN HUB variables
  eu_id           = "EMEA"
  eu_hub_bgp_asn  = "65001" // iBGP RR server
  eu_hub_cidr     = "10.1.0.0/16"
  eu_hub_vpn_cidr = "172.16.100.0/24" // VPN DialUp spokes cidr
  eu_hub_vpn_ddns = "eu-hub-cwan-vpn"
  eu_hub_vpn_fqdn = "${local.eu_hub_vpn_ddns}.${local.route53_zone_name}"

  # EU VPC SPOKE TO CORE NETWORK
  eu_spoke_to_core_net_number = 2
  eu_spoke_to_core_net = { for i in range(0, local.eu_spoke_to_core_net_number) :
    "eu-spoke-to-corenet-${i}" => "10.1.${i + 101}.0/24"
  }

  #-----------------------------------------------------------------------------------------------------
  # EU - EMEA SDWAN SPOKE
  #-----------------------------------------------------------------------------------------------------
  # General variables 
  eu_sdwan_number_peer_az = 1
  eu_sdwan_azs            = ["eu-west-2a"]

  # VPN HUB variables
  eu_sdwan_number  = 0
  eu_spoke_bgp_asn = "65000"

  eu_sdwan_spoke = [for i in range(0, local.eu_sdwan_number) :
    { "id"      = "eu-office-${i + 1}"
      "cidr"    = "192.168.${i + 101}.0/24"
      "bgp_asn" = local.eu_spoke_bgp_asn
    }
  ]

}