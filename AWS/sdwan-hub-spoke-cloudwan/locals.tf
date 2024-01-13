locals {
  ## Generate locals needed at modules ##

  #-----------------------------------------------------------------------------------------------------
  # FGT VPC generic variables
  #-----------------------------------------------------------------------------------------------------
  # List of subnet names to add a route to FGT NI
  ni_rt_subnet_names = ["bastion", "corenet"]
  # List of subnet names to add a route to a Core Network
  core_net_rt_subnet_names = [local.eu_hub_fgt_subnet_tags["port2.private"]]

  #-----------------------------------------------------------------------------------------------------
  # HUB EMEA (EU)
  #-----------------------------------------------------------------------------------------------------
  # List of public and private subnet to create FGT VPC
  eu_hub_fgt_vpc_public_subnet_names  = [local.eu_hub_fgt_subnet_tags["port1.public"], local.eu_hub_fgt_subnet_tags["port3.mgmt"], "bastion"]
  eu_hub_fgt_vpc_private_subnet_names = [local.eu_hub_fgt_subnet_tags["port2.private"], "corenet"]

  # Config VPN DialUps FGT HUB
  eu_hub = [
    {
      id                = local.eu_id
      bgp_asn_hub       = local.eu_hub_bgp_asn
      bgp_asn_spoke     = local.eu_spoke_bgp_asn
      vpn_cidr          = local.eu_hub_vpn_cidr
      vpn_psk           = trimspace(random_string.vpn_psk.result)
      cidr              = local.eu_hub_cidr
      ike_version       = "2"
      network_id        = "1"
      dpd_retryinterval = "5"
      mode_cfg          = true
      vpn_port          = "public"
      local_gw          = ""
    }
  ]
  # Create map of RT IDs add routes pointing to a FGT NI
  eu_hub_ni_rt_ids = {
    for pair in setproduct(local.ni_rt_subnet_names, [for i, az in local.eu_azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.eu_hub_vpc.rt_ids[pair[1]][pair[0]]
  }
  # Create map of RT IDs add routes pointing to a CoreNet ARN
  eu_hub_core_net_rt_ids = {
    for pair in setproduct(local.core_net_rt_subnet_names, [for i, az in local.eu_azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.eu_hub_vpc.rt_ids[pair[1]][pair[0]]
  }
  # Map of public IPs of EU HUB
  eu_hub_public_eips = module.eu_hub_nis.fgt_eips_map

  #-----------------------------------------------------------------------------------------------------
  # EU - EMEA SDWAN SPOKE
  #-----------------------------------------------------------------------------------------------------
  # EU HUBs variables
  eu_hub_public_ip  = ""
  eu_hub_private_ip = ""
  eu_op_public_ip   = ""
  eu_op_private_ip  = ""

  eu_hubs = concat(local.eu_hubs_cloud)

  # Define SDWAN HUB EMEA CLOUD
  eu_hubs_cloud = [for hub in local.eu_hub :
    {
      id      = hub["id"]
      bgp_asn = hub["bgp_asn_hub"]
      // external_ip       = hub["vpn_port"] == "public" ? local.eu_hub_public_ip : local.eu_hub_private_ip
      external_fqdn     = hub["vpn_port"] == "public" ? local.eu_hub_vpn_fqdn : local.eu_hub_private_ip
      hub_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], 0, 0), 1)
      site_ip           = hub["mode_cfg"] ? "" : cidrhost(cidrsubnet(hub["vpn_cidr"], 0), 3)
      hck_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], 0, 0), 1)
      vpn_psk           = hub["vpn_psk"]
      cidr              = hub["cidr"]
      ike_version       = hub["ike_version"]
      network_id        = hub["network_id"]
      dpd_retryinterval = hub["dpd_retryinterval"]
      sdwan_port        = hub["vpn_port"]
    }
  ]
  # Create map of RT IDs
  eu_sdwan_ni_rt_ids = [
    for i in range(0, local.eu_sdwan_number) : {
      for pair in setproduct(local.ni_rt_subnet_names, [for i, az in local.eu_sdwan_azs : "az${i + 1}"]) :
      "${pair[0]}-${pair[1]}" => module.eu_sdwan_vpc[i].rt_ids[pair[1]][pair[0]]
    }
  ]
  # Create FGTs config (auxiliary local list)
  eu_sdwan_config = flatten([
    for i in range(0, local.eu_sdwan_number) :
    [for ii, v in local.eu_sdwan_azs :
      { "sdwan_id" = "${i}"
        "fgt_id"   = "az${ii + 1}.fgt${ii + 1}"
      }
    ]
    ]
  )
}