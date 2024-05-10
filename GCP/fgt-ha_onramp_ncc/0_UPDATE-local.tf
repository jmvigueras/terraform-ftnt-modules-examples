locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  region = "europe-west2"
  zone1  = "europe-west2-a"
  zone2  = "europe-west2-b"
  prefix = "demo-fgt-ncc"
  #-----------------------------------------------------------------------------------------------------
  # FGT
  #-----------------------------------------------------------------------------------------------------
  license_type = "payg"
  machine      = "n1-standard-4"

  admin_port = "8443"
  admin_cidr = "${chomp(data.http.my-public-ip.response_body)}/32"

  onramp = {
    id      = "fgt"
    cidr    = "172.30.0.0/23" //minimum range to create proxy subnet
    bgp_asn = "65000"
  }

  cluster_type = "fgcp"
  fgt_passive  = true
  #-----------------------------------------------------------------------------------------------------
  # VPC spokes peered to VPC private
  #-----------------------------------------------------------------------------------------------------
  vpc_spoke-subnet_cidrs = ["172.30.10.0/23", "172.30.20.0/23"]

  #-----------------------------------------------------------------------------------------------------
  # NCC
  #-----------------------------------------------------------------------------------------------------
  ncc_bgp-asn = "65515"
}