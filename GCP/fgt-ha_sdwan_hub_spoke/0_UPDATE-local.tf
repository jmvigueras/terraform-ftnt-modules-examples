locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  region = "europe-west2"
  zone1  = "europe-west2-a"
  zone2  = "europe-west2-b"
  prefix = "cloud-sdwan"

  #-----------------------------------------------------------------------------------------------------
  # General
  #-----------------------------------------------------------------------------------------------------
  fgt_license_type = "payg"
  fgt_version      = "728"
  fgt_machine      = "n1-standard-4"

  admin_port = "8443"
  admin_cidr = "0.0.0.0/0"

  #-----------------------------------------------------------------------------------------------------
  # HUB
  #-----------------------------------------------------------------------------------------------------
  hub_cidr = "10.10.0.0/23"

  hub = [
    {
      id                = "HUB"
      bgp-asn_hub       = "65000"
      bgp-asn_spoke     = "65000"
      vpn_cidr          = "172.16.0.0/24"
      vpn_psk           = random_string.vpn_psk.result
      cidr              = "10.10.0.0/16"
      ike-version       = "2"
      network_id        = "1"
      dpd-retryinterval = "10"
      mode_cfg          = true
      local_gw          = module.hub_xlb.elb-frontend
      vpn_port          = "public"
    }
  ]

  #-----------------------------------------------------------------------------------------------------
  # SDWAN Spokes
  #-----------------------------------------------------------------------------------------------------
  # VPN HUB variables
  sdwan_number  = 1

  sdwan_spokes = [for i in range(0, local.sdwan_number) :
    { "id"      = "spoke-${i + 1}"
      "cidr"    = "172.10.${i * 2}.0/23"
      "bgp_asn" = local.hub[0]["bgp-asn_spoke"]
    }
  ]

  hubs = [for i, v in local.hub :
    {
      id                = v["id"]
      bgp_asn           = v["bgp-asn_hub"]
      external_ip       = v["vpn_port"] == "public" ? module.hub_xlb.elb-frontend : module.hub_vpc.fgt-active-ni_ips["private"]
      hub_ip            = cidrhost(v["vpn_cidr"], 1)
      site_ip           = ""
      hck_ip            = cidrhost(v["vpn_cidr"], 1)
      vpn_psk           = v["vpn_psk"]
      cidr              = v["vpn_psk"]
      ike_version       = v["ike-version"]
      network_id        = v["network_id"]
      dpd_retryinterval = v["dpd-retryinterval"]
      sdwan_port        = v["vpn_port"]
    }
  ]
}