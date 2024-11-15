locals {
  # fgt_id
  fgt_id = var.config_spoke ? "${var.spoke["id"]}-${var.fgt_id}" : var.config_hub ? "${var.hub[0]["id"]}-${var.fgt_id}" : var.fgt_id

  # -----------------------------------------------------------------------------------------------------
  # FGSP locals
  # -----------------------------------------------------------------------------------------------------
  # FGSP member ID
  fgsp_member_id = var.fgsp_member_id
  # List of FGSP peer ips
  fgsp_peer_ips = [
    for k, v in var.fgsp_member_ips : v if k != local.fgsp_member_id
  ]
  # -----------------------------------------------------------------------------------------------------
  # AutoScale config
  # -----------------------------------------------------------------------------------------------------
  # AutoScale port name
  as_port_name = var.private_port
  # FGSP master is the member_id = 0 
  as_master_ip = var.fgsp_member_id == "0" ? "" : local.fgsp_peer_ips[0]

  # -----------------------------------------------------------------------------------------------------
  # VXLAN peers BGP
  # -----------------------------------------------------------------------------------------------------
  vxlan_peers_bgp = flatten([
    for i, v in var.vxlan_peers : [
      for ip in split(",", v["remote_ip"]) :
      { bgp_asn       = v["bgp_asn"]
        remote_ip     = trimspace(ip)
        route_map_in  = lookup(v, "route_map_in", "")
        route_map_out = lookup(v, "route_map_out", "")
        local_cidr    = lookup(v, "local_cidr", "")
      }
    ]
    ]
  )
}