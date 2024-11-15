##############################################################################################################
# FGT ACTIVE VM
##############################################################################################################
# Create new random API key to be provisioned in FortiGates.
resource "random_string" "vpn_psk" {
  length  = 30
  special = false
  numeric = true
}

# Create new random FGSP secret
resource "random_string" "fgsp_auto-config_secret" {
  length  = 10
  special = false
  numeric = true
}

# Create new random FGSP secret
resource "random_string" "api_key" {
  length  = 30
  special = false
  numeric = true
}

data "template_file" "fgt" {
  template = file("${path.module}/templates/fgt_all.conf")

  vars = {
    fgt_id          = local.fgt_id
    admin_port      = var.admin_port
    admin_cidr      = var.admin_cidr
    adminusername   = "admin"
    type            = var.license_type
    license_file    = var.license_file
    fortiflex_token = var.fortiflex_token
    rsa_public_key  = trimspace(var.rsa_public_key)
    api_key         = var.api_key == null ? random_string.api_key.result : var.api_key

    public_port  = var.public_port
    public_ip    = var.fgt_ips["public"]
    public_mask  = cidrnetmask(var.fgt_subnet_cidrs["public"])
    public_gw    = cidrhost(var.fgt_subnet_cidrs["public"], 1)
    private_port = var.private_port
    private_ip   = var.fgt_ips["private"]
    private_mask = cidrnetmask(var.fgt_subnet_cidrs["private"])
    private_gw   = cidrhost(var.fgt_subnet_cidrs["private"], 1)

    config_fw_policy     = var.config_fw_policy ? data.template_file.config_fw_policy.rendered : ""
    config_sdn           = data.template_file.config_sdn.rendered
    config_fgsp          = var.config_fgsp ? data.template_file.config_fgsp.rendered : ""
    config_scale         = var.config_auto_scale ? data.template_file.config_auto_scale.rendered : ""
    config_router_bgp    = data.template_file.config_router_bgp.rendered
    config_router_static = var.vcn_spoke_cidrs != null ? data.template_file.config_router_static.rendered : ""
    config_sdwan         = var.config_spoke ? join("\n", data.template_file.config_sdwan_fgt.*.rendered) : ""
    config_vxlan         = var.config_vxlan ? join("\n", data.template_file.config_vxlan.*.rendered, data.template_file.config_vxlan_bgp.*.rendered) : ""
    config_s2s           = var.config_s2s ? join("\n", data.template_file.config_s2s.*.rendered) : ""
    config_vpn           = var.config_hub ? join("\n", data.template_file.config_vpn_fgt.*.rendered) : ""
    config_fmg           = var.config_fmg ? data.template_file.config_fmg_fgt.rendered : ""
    config_faz           = var.config_faz ? data.template_file.config_faz_fgt.rendered : ""
    config_extra         = var.config_extra
  }
}

data "template_file" "config_fw_policy" {
  template = file("${path.module}/templates/fgt_fw_policy.conf")
  vars = {
    port = var.public_port
  }
}

data "template_file" "config_sdn" {
  template = file("${path.module}/templates/oci_fgt_sdn.conf")
  vars = {
    tenancy_ocid     = var.tenancy_ocid
    compartment_ocid = var.compartment_ocid
  }
}

data "template_file" "config_fgsp" {
  template = file("${path.module}/templates/fgt_ha_fgsp.conf")
  vars = {
    peers_list = join("\n", data.template_file.config_fgsp_peers.*.rendered)
    member_id  = local.fgsp_member_id + 1
  }
}
data "template_file" "config_fgsp_peers" {
  count    = length(local.fgsp_peer_ips)
  template = file("${path.module}/templates/fgt_ha_fgsp_peers.conf")
  vars = {
    id = count.index + 1
    ip = local.fgsp_peer_ips[count.index]
  }
}

data "template_file" "config_auto_scale" {
  template = file("${path.module}/templates/fgt_auto_scale.conf")
  vars = {
    sync_port     = local.as_port_name
    master_secret = var.auto_scale_secret
    master_ip     = local.as_master_ip
  }
}

data "template_file" "config_router_bgp" {
  template = file("${path.module}/templates/fgt_bgp.conf")
  vars = {
    bgp_asn     = var.config_hub ? var.hub[0]["bgp_asn_hub"] : var.config_spoke ? var.spoke["bgp_asn"] : var.bgp_asn_default
    router_id   = var.fgt_ips["public"]
    bgp_network = var.bgp_network != null ? var.bgp_network : ""
  }
}

data "template_file" "config_router_static" {
  template = templatefile("${path.module}/templates/fgt_static.conf", {
    vpc-spoke_cidr = var.vcn_spoke_cidrs
    port           = var.private_port
    gw             = cidrhost(var.fgt_subnet_cidrs["private"], 1)
  })
}

data "template_file" "config_sdwan_fgt" {
  count    = var.hubs != null ? length(var.hubs) : 0
  template = file("${path.module}/templates/fgt_sdwan.conf")
  vars = {
    hub_id            = var.hubs[count.index]["id"]
    hub_ipsec_id      = "${var.hubs[count.index]["id"]}_ipsec_${count.index + 1}"
    hub_vpn_psk       = var.hubs[count.index]["vpn_psk"] == "" ? random_string.vpn_psk.result : var.hubs[count.index]["vpn_psk"]
    hub_external_ip   = var.hubs[count.index]["external_ip"]
    hub_private_ip    = var.hubs[count.index]["hub_ip"]
    site_private_ip   = var.hubs[count.index]["site_ip"]
    hub_bgp_asn       = var.hubs[count.index]["bgp_asn"]
    hck_ip            = var.hubs[count.index]["hck_ip"]
    hub_cidr          = var.hubs[count.index]["cidr"]
    network_id        = var.hubs[count.index]["network_id"]
    ike_version       = var.hubs[count.index]["ike_version"]
    dpd_retryinterval = var.hubs[count.index]["dpd_retryinterval"]
    local_id          = "${var.spoke["id"]}-1"
    local_bgp_asn     = var.spoke["bgp_asn"]
    local_router_id   = var.fgt_ips["public"]
    local_network     = var.spoke["cidr"]
    sdwan_port        = var.ports[var.hubs[count.index]["sdwan_port"]]
    private_port      = var.ports["private"]
    count             = count.index + 1
  }
}

data "template_file" "config_vpn_fgt" {
  count    = length(var.hub)
  template = file("${path.module}/templates/fgt_vpn.conf")
  vars = {
    hub_private_ip        = cidrhost(cidrsubnet(var.hub[count.index]["vpn_cidr"], 1, 0), 1)
    hub_remote_ip         = cidrhost(cidrsubnet(var.hub[count.index]["vpn_cidr"], 1, 0), 2)
    network_id            = var.hub[count.index]["network_id"]
    ike_version           = var.hub[count.index]["ike_version"]
    dpd_retryinterval     = var.hub[count.index]["dpd_retryinterval"]
    local_id              = var.hub[count.index]["id"]
    local_bgp_asn         = var.hub[count.index]["bgp_asn_hub"]
    local_network         = var.hub[count.index]["cidr"]
    mode_cfg              = var.hub[count.index]["mode_cfg"]
    site_private_ip_start = cidrhost(cidrsubnet(var.hub[count.index]["vpn_cidr"], 1, 0), 3)
    site_private_ip_end   = cidrhost(cidrsubnet(var.hub[count.index]["vpn_cidr"], 1, 0), 14)
    site_private_ip_mask  = cidrnetmask(cidrsubnet(var.hub[count.index]["vpn_cidr"], 1, 0))
    site_bgp_asn          = var.hub[count.index]["bgp_asn_spoke"]
    vpn_psk               = var.hub[count.index]["vpn_psk"] == "" ? random_string.vpn_psk.result : var.hub[count.index]["vpn_psk"]
    vpn_cidr              = cidrsubnet(var.hub[count.index]["vpn_cidr"], 1, 0)
    vpn_port              = var.ports[var.hub[count.index]["vpn_port"]]
    vpn_name              = "vpn-${var.hub[count.index]["vpn_port"]}"
    private_port          = var.ports["private"]
    // route_map_out         = "rm_out_aspath_0"
    route_map_out = ""
    count         = count.index + 1
  }
}

# Create Site to Site config with SDWAN
data "template_file" "config_s2s" {
  count    = length(var.s2s_peers)
  template = file("${path.module}/templates/fgt_site_to_site.conf")
  vars = {
    id                = var.s2s_peers[count.index]["id"]
    remote_gw         = var.s2s_peers[count.index]["remote_gw"]
    local_gw          = lookup(var.s2s_peers[count.index], "local_gw", "")
    vpn_intf_id       = "${var.s2s_peers[count.index]["id"]}_ipsec_${count.index + 1}"
    vpn_remote_ip     = var.s2s_peers[count.index]["vpn_remote_ip"]
    vpn_local_ip      = var.s2s_peers[count.index]["vpn_local_ip"]
    vpn_cidr_mask     = cidrnetmask(var.s2s_peers[count.index]["vpn_cidr"])
    vpn_psk           = var.s2s_peers[count.index]["vpn_psk"]
    vpn_port          = var.ports[var.s2s_peers[count.index]["vpn_port"]]
    network_id        = lookup(var.s2s_peers[count.index], "network_id", "11")
    ike_version       = lookup(var.s2s_peers[count.index], "ike_version", "2")
    dpd_retryinterval = lookup(var.s2s_peers[count.index], "dpd_retryinterval", "5")
    bgp_asn_remote    = var.s2s_peers[count.index]["bgp_asn_remote"]
    hck_ip            = var.s2s_peers[count.index]["hck_ip"]
    remote_cidr       = var.s2s_peers[count.index]["remote_cidr"]
    count             = count.index + 1
  }
}

data "template_file" "config_vxlan" {
  count    = length(var.vxlan_peers)
  template = file("${path.module}/templates/fgt_vxlan.conf")
  vars = {
    vni         = var.vxlan_peers[count.index]["vni"]
    external_ip = replace(var.vxlan_peers[count.index]["external_ip"], ",", " ")
    local_ip    = var.vxlan_peers[count.index]["local_ip"]
    vxlan_port  = var.ports[var.vxlan_peers[count.index]["vxlan_port"]]
    count       = count.index + 1
  }
}

data "template_file" "config_vxlan_bgp" {
  count    = length(local.vxlan_peers_bgp)
  template = file("${path.module}/templates/fgt_vxlan_bgp.conf")
  vars = {
    remote_ip     = local.vxlan_peers_bgp[count.index]["remote_ip"]
    bgp_asn       = local.vxlan_peers_bgp[count.index]["bgp_asn"]
    route_map_out = local.vxlan_peers_bgp[count.index]["route_map_out"]
    route_map_in  = local.vxlan_peers_bgp[count.index]["route_map_in"]
    local_cidr    = local.vxlan_peers_bgp[count.index]["local_cidr"]
    count_index   = count.index
  }
}

data "template_file" "config_faz_fgt" {
  template = file("${path.module}/templates/fgt_faz.conf")
  vars = {
    ip                      = var.faz_ip
    sn                      = var.faz_sn
    source-ip               = var.faz_source_ip_fgt
    interface-select-method = var.faz_interface_select_method
  }
}

data "template_file" "config_fmg_fgt" {
  template = file("${path.module}/templates/fgt_fmg.conf")
  vars = {
    ip                      = var.fmg_ip
    sn                      = var.fmg_sn
    source-ip               = var.fmg_source_ip_fgt
    interface-select-method = var.fmg_interface_select_method
  }
}