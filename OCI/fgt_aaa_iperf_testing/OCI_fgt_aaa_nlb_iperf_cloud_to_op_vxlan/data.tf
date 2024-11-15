locals {
  #-----------------------------------------------------------------------------------------------------
  # HUB OCI variables
  #-----------------------------------------------------------------------------------------------------
  fgt_subnet_cidrs = module.hub_oci_vcn.fgt_subnet_cidrs
  subnet_cidr_host = 5
  # Map of ips of each FGSP cluster members
  fgsp_member_ips = { for i in range(0, local.hub_oci_fgsp_cluster_number) :
    i => cidrhost(local.fgt_subnet_cidrs["private"], local.subnet_cidr_host + i)
  }
  # Map of IPs for each fortigate
  hub_oci_fgt_ips = { for i in range(0, local.hub_oci_fgsp_cluster_number) : i => {
    "public"  = cidrhost(local.fgt_subnet_cidrs["public"], local.subnet_cidr_host + i),
    "private" = cidrhost(local.fgt_subnet_cidrs["private"], local.subnet_cidr_host + i)
    }
  }
  # List of a list of map with VXLAN HUB OP data
  hub_oci_peer_vxlan = { for k, v in local.hub_oci_fgt_ips : k => [
    {
      external_ip   = module.hub_op_vcn.fgt_1_ips["private"]
      remote_ip     = "10.10.30.1"
      local_ip      = "10.10.30.${k + 2}"
      bgp_asn       = local.bgp_asn
      vni           = "1100"
      vxlan_port    = "private"
      route_map_in  = ""
      route_map_out = ""
      local_cidr    = try(local.hub_oci_spokes_cidrs[0], local.hub_oci_vcn_cidr)
    }
    ]
  }
  #-----------------------------------------------------------------------------------------------------
  # HUB OP variables
  #-----------------------------------------------------------------------------------------------------
  # List of map with VXLAN HUB OP data
  hub_op_peer_vxlan = [
    {
      external_ip   = join(",", [for k, v in local.hub_oci_fgt_ips : v["private"]])
      remote_ip     = join(",", [for i in range(0, local.hub_oci_fgsp_cluster_number) : "10.10.30.${i + 2}"])
      local_ip      = "10.10.30.1"
      bgp_asn       = local.bgp_asn
      vni           = "1100"
      vxlan_port    = "private"
      route_map_in  = ""
      route_map_out = ""
      local_cidr    = local.hub_op_vcn_cidr
    }
  ]
}