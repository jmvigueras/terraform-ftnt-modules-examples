locals {
  # fgt_id
  fgt_1_id = var.config_spoke ? "${var.spoke["id"]}-${var.fgt_id}-1" : var.config_hub ? "${var.hub[0]["id"]}-${var.fgt_id}-1" : "${var.fgt_id}-1"
  fgt_2_id = var.config_spoke ? "${var.spoke["id"]}-${var.fgt_id}-2" : var.config_hub ? "${var.hub[0]["id"]}-${var.fgt_id}-2" : "${var.fgt_id}-2"
  
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