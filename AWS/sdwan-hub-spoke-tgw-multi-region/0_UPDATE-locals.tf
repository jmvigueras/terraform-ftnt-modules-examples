#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  prefix = "global-sdwan"

  tags = {
    Project = "ftnt_modules_aws"
  }

  eu_region = "eu-south-2"
  eu_azs    = ["eu-south-2a", "eu-south-2b"]

  admin_port = "8443"
  admin_cidr = "${chomp(data.http.my-public-ip.response_body)}/32"
  //admin_cidr    = "0.0.0.0/0"
  instance_type = "c6in.large"
  fgt_build     = "build1639"
  license_type  = "payg"

  route53_zone_name = "fortidemoscloud.com"

  #-----------------------------------------------------------------------------------------------------
  # EU - EMEA HUB
  #-----------------------------------------------------------------------------------------------------
  # fgt_subnet_tags -> add tags to FGT subnets (port1, port2, public, private ...)
  eu_hub_fgt_subnet_tags = {
    "port1.public"  = "net-public"
    "port2.private" = "net-private"
    "port3.mgmt"    = ""
  }

  # General variables 
  eu_hub_number_peer_az = 1
  eu_hub_cluster_type   = "fgsp"
  eu_hub_vpc_cidr       = "10.1.0.0/24"

  # VPN HUB variables
  eu_id           = "EMEA"
  eu_hub_bgp_asn  = "65001" // iBGP RR server
  eu_hub_cidr     = "10.1.0.0/16"
  eu_hub_vpn_cidr = "172.16.100.0/24" // VPN DialUp spokes cidr
  eu_hub_vpn_ddns = "eu-hub-vpn"
  eu_hub_vpn_fqdn = "${local.eu_hub_vpn_ddns}.${local.route53_zone_name}"

  # VXLAN HUB to HUB variables
  eu_hub_vxlan_cidr = "172.16.11.0/24" // VXLAN cluster members cidr
  eu_hub_vxlan_vni  = "1101"           // VXLAN cluster members vni ID 

  eu_hub_to_op_vxlan_cidr = "172.16.12.0/24" // VXLAN to OP cidr
  eu_hub_to_op_vxlan_vni  = "1102"           // VXLAN to OP VNI ID

  eu_hub_to_us_hub_vxlan_cidr = "172.16.13.0/24" // VXLAN to US cidr
  eu_hub_to_us_hub_vxlan_vni  = "1103"           // VXLAN to US VNI ID

  # EU HUB TGW
  eu_tgw_cidr    = "10.1.10.0/24"
  eu_tgw_bgp_asn = "65011"

  # EU VPC SPOKE TO TGW
  eu_spoke_to_tgw_number = 2
  eu_spoke_to_tgw = { for i in range(0, local.eu_spoke_to_tgw_number) :
    "eu-spoke-to-tgw-${i}" => "10.1.${i + 101}.0/24"
  }

  #-----------------------------------------------------------------------------------------------------
  # EU - EMEA SDWAN SPOKE
  #-----------------------------------------------------------------------------------------------------
  # General variables 
  eu_sdwan_number_peer_az = 1
  eu_sdwan_azs            = ["eu-south-2a"]

  # VPN HUB variables
  eu_sdwan_number  = 2
  eu_spoke_bgp_asn = "65000"

  eu_sdwan_spoke = [for i in range(0, local.eu_sdwan_number) :
    { "id"      = "eu-office-${i + 1}"
      "cidr"    = "10.1.${i + 201}.0/24"
      "bgp_asn" = local.eu_spoke_bgp_asn
    }
  ]

  #-----------------------------------------------------------------------------------------------------
  # EU - EMEA ON-PREMISE HUB
  #-----------------------------------------------------------------------------------------------------
  us_region = "eu-south-2"
  us_azs    = ["eu-south-2a", "eu-south-2b"]

  # fgt_subnet_tags -> add tags to FGT subnets (port1, port2, public, private ...)
  eu_op_fgt_subnet_tags = {
    "port1.public"  = "net-public"
    "port2.private" = "net-private"
    "port3.mgmt"    = "net-mgmt"
  }

  # General variables 
  eu_op_number_peer_az = 1
  eu_op_cluster_type   = "fgcp"
  eu_op_vpc_cidr       = "10.2.0.0/24"

  # VPN HUB variables
  eu_op_bgp_asn  = "65002" // iBGP RR server
  eu_op_cidr     = "10.2.0.0/16"
  eu_op_vpn_cidr = "172.20.100.0/24" // VPN DialUp spokes cidr

  eu_op_vpn_ddns = "eu-op-vpn"
  eu_op_vpn_fqdn = "${local.eu_op_vpn_ddns}.${local.route53_zone_name}"

  #-----------------------------------------------------------------------------------------------------
  # US - NORAM HUB
  #-----------------------------------------------------------------------------------------------------
  # fgt_subnet_tags -> add tags to FGT subnets (port1, port2, public, private ...)
  us_hub_fgt_subnet_tags = {
    "port1.public"  = "net-public"
    "port2.private" = "net-private"
    "port3.mgmt"    = "net-mgmt"
  }

  # General variables 
  us_hub_number_peer_az = 1
  us_hub_cluster_type   = "fgcp"
  us_hub_vpc_cidr       = "10.3.0.0/24"

  # VPN HUB variables
  us_id           = "NORAM"
  us_hub_bgp_asn  = "65003" // iBGP RR server
  us_hub_cidr     = "10.3.0.0/16"
  us_hub_vpn_cidr = "172.30.100.0/24" // VPN DialUp spokes cidr
  us_hub_vpn_ddns = "us-hub-vpn"
  us_hub_vpn_fqdn = "${local.us_hub_vpn_ddns}.${local.route53_zone_name}"

  # US HUB TGW
  us_tgw_cidr    = "10.3.10.0/24"
  us_tgw_bgp_asn = "65013"

  # US VPC SPOKE TO TGW
  us_spoke_to_tgw_number = 2
  us_spoke_to_tgw = { for i in range(0, local.us_spoke_to_tgw_number) :
    "us-spoke-to-tgw-${i}" => "10.3.${i + 101}.0/24"
  }

  #-----------------------------------------------------------------------------------------------------
  # US - NORAM SDWAN SPOKE
  #-----------------------------------------------------------------------------------------------------
  # General variables 
  us_sdwan_number_peer_az = 1
  us_sdwan_azs            = ["eu-south-2a"]

  # SPOKE SDWAN VPN HUB variables
  us_sdwan_number  = 2
  us_spoke_bgp_asn = "65000"

  us_sdwan_spoke = [for i in range(0, local.us_sdwan_number) :
    { "id"      = "us-office-${i + 1}"
      "cidr"    = "10.3.${i + 201}.0/24"
      "bgp_asn" = local.us_spoke_bgp_asn
    }
  ]
}
