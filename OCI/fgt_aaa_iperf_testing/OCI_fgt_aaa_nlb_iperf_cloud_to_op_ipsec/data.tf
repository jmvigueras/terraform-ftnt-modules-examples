locals {
  #-----------------------------------------------------------------------------------------------------
  # HUB OCI variables
  #--------------------------------------------------------------------------------------------------
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
  # List of a list of map of S2S peers
  hub_oci_s2s_peers = { for k, v in local.hub_oci_fgt_ips : k => [{
    id             = "to-op"
    remote_gw      = module.hub_op_vcn.fgt_1_ips["private"]
    bgp_asn_remote = local.bgp_asn
    vpn_port       = "private"
    vpn_cidr       = "10.10.${30 + k + 1}.0/27"
    vpn_psk        = "secret-key-123"
    vpn_local_ip   = "10.10.${30 + k + 1}.2"
    vpn_remote_ip  = "10.10.${30 + k + 1}.1"
    hck_ip         = "10.10.${30 + k + 1}.1"
    remote_cidr    = local.hub_op_cidr
    }]
  }
  #-----------------------------------------------------------------------------------------------------
  # HUB OP variables
  #-----------------------------------------------------------------------------------------------------
  # List of map with VXLAN HUB OP data
  hub_op_s2s_peers = [for k, v in local.hub_oci_fgt_ips : {
    id             = "to-oci"
    remote_gw      = v["private"]
    bgp_asn_remote = local.bgp_asn
    vpn_port       = "private"
    vpn_cidr       = "10.10.${30 + k + 1}.0/27"
    vpn_psk        = "secret-key-123"
    vpn_local_ip   = "10.10.${30 + k + 1}.1"
    vpn_remote_ip  = "10.10.${30 + k + 1}.2"
    hck_ip         = "10.10.${30 + k + 1}.2"
    remote_cidr    = local.hub_oci_cidr
    }
  ]
}