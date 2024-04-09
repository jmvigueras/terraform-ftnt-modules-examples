#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  prefix = "dual-vpc-inspection"

  tags = {
    Project = "ftnt_modules_aws"
  }

  region = "eu-west-1"
  azs    = ["eu-west-1a", "eu-west-1b"] // List of AZs to deploy
  
  admin_port = "8443"
  //admin_cidr = "${chomp(data.http.my-public-ip.response_body)}/32"
  admin_cidr    = "0.0.0.0/0"

  instance_type = "c6i.large"
  fgt_build     = "build1577"
  license_type  = "payg"  // both values "payg" either "byol"

  # TGW - CIDR
  tgw_cidr    = "172.20.30.0/24" // Optional CIDR range for TGW
  tgw_bgp_asn = "65002" // Configure BGP ASN for TGW

  #-----------------------------------------------------------------------------------------------------
  # N-S fortigate cluster
  #-----------------------------------------------------------------------------------------------------
  ns_fgt_number_peer_az = 1
  ns_fgt_cluster_type   = "fgcp" // choose type of cluster either fgsp or fgcp  

  # fgt_subnet_tags -> add tags to FGT subnets (port1, port2, public, private ...)
  # - FGCP type of cluster requires a management port
  # - port1 must have Internet access in terms of validate license in case of using FortiFlex token or lic file. 
  ns_fgt_subnet_tags = {
    "port1.public"  = "public"
    "port2.private" = "private"
    "port3.mgmt"    = "mgmt"
  }

  # VPC - list of public and private subnet names
  ns_public_subnet_names  = [local.ns_fgt_subnet_tags["port1.public"], local.ns_fgt_subnet_tags["port3.mgmt"]]
  ns_private_subnet_names = [local.ns_fgt_subnet_tags["port2.private"], "tgw"]

  # VPC - CIDR
  ns_fgt_vpc_cidr = "172.20.0.0/24"

  #-----------------------------------------------------------------------------------------------------
  # E-W fortigate cluster
  #-----------------------------------------------------------------------------------------------------
  ew_fgt_number_peer_az = 1
  ew_fgt_cluster_type   = "fgsp" // choose type of cluster either fgsp or fgcp  

  # fgt_subnet_tags -> add tags to FGT subnets (port1, port2, public, private ...)
  # - FGCP type of cluster requires a management port
  # - port1 must have Internet access in terms of validate license in case of using FortiFlex token or lic file. 
  ew_fgt_subnet_tags = {
    "port1.public"  = "public"
    "port2.private" = "private"
  }

  # VPC - list of public and private subnet names
  ew_public_subnet_names  = [local.ew_fgt_subnet_tags["port1.public"]]
  ew_private_subnet_names = [local.ew_fgt_subnet_tags["port2.private"], "tgw", "gwlb"]

  # VPC - CIDR
  ew_fgt_vpc_cidr = "172.20.10.0/24"

  #-----------------------------------------------------------------------------------------------------
  # VPC - Services
  #-----------------------------------------------------------------------------------------------------
  # VPC - CIDR
  vpc_spokes_cidrs = ["172.20.100.0/24", "172.20.150.0/24"]
  # VPC - list of public and private subnet names
  vpc_spokes_public_subnet_names  = ["vm"]
  vpc_spokes_private_subnet_names = ["tgw", "gwlb"]
}
