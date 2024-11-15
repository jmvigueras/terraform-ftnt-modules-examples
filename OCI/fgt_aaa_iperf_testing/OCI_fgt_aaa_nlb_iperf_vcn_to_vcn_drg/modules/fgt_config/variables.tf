#-----------------------------------------------------------------------------------
# Predefined variables for cluster
# - FGSP and AutoScale
#-----------------------------------------------------------------------------------
variable "config_fgsp" {
  type    = bool
  default = false
}
variable "fgsp_member_id" {
  type    = string
  default = "0"
}
variable "fgsp_member_ips" {
  type    = map(string)
  default = {}
}
variable "fgsp_port" {
  type    = string
  default = "private"
}
variable "auto_scale_secret" {
  description = "Fortigate auto scale password"
  type        = string
  default     = "nh62znfkzajz2o9"
}
variable "config_auto_scale" {
  description = "Configure auto-scale"
  type    = bool
  default = false
}
#-----------------------------------------------------------------------------------
# Default BGP configuration
#-----------------------------------------------------------------------------------
variable "bgp_asn_default" {
  type    = string
  default = "65000"
}
#-----------------------------------------------------------------------------------
# Predefined variables for spoke config
# - config_spoke   = false (default) 
#-----------------------------------------------------------------------------------
variable "config_spoke" {
  type    = bool
  default = false
}
// Default parameters to configure a site
variable "spoke" {
  type = map(any)
  default = {
    id      = "fgt"
    cidr    = "192.168.0.0/24"
    bgp_asn = "65000"
  }
}
// Details to crate VPN connections
variable "hubs" {
  type = list(map(string))
  default = [
    {
      id                = "HUB"
      bgp_asn           = "65000"
      external_ip       = "11.11.11.11"
      hub_ip            = "172.20.30.1"
      site_ip           = "172.20.30.10" // set to "" if VPN mode_cfg is enable
      hck_ip            = "172.20.30.1"
      vpn_psk           = "secret"
      cidr              = "172.20.30.0/24"
      ike_version       = "2"
      network_id        = "1"
      dpd_retryinterval = "5"
      sdwan_port        = "public"
    }
  ]
}
#-----------------------------------------------------------------------------------
# Predefined variables for HUB
# - config_hub   = false (default) 
#-----------------------------------------------------------------------------------
variable "config_hub" {
  type    = bool
  default = false
}
// Variable to create VPN HUB
variable "hub" {
  type = list(map(string))
  default = [
    {
      id                = "HUB"
      bgp_asn_hub       = "65000"
      bgp_asn_spoke     = "65000"
      vpn_cidr          = "10.1.1.0/24"
      vpn_psk           = "secret-key-123"
      cidr              = "172.30.0.0/24"
      ike_version       = "2"
      network_id        = "1"
      dpd_retryinterval = "5"
      mode_cfg          = true
      vpn_port          = "public"
    },
    {
      id                = "HUB"
      bgp_asn_hub       = "65000"
      bgp_asn_spoke     = "65000"
      vpn_cidr          = "10.1.10.0/24"
      vpn_psk           = "secret-key-123"
      cidr              = "172.30.0.0/24"
      ike_version       = "2"
      network_id        = "1"
      dpd_retryinterval = "5"
      mode_cfg          = true
      vpn_port          = "private"
    }
  ]
}
#-----------------------------------------------------------------------------------
# Config VXLAN tunnels
# - config_hub   = false (default) 
#-----------------------------------------------------------------------------------
variable "config_vxlan" {
  description = "Boolean varible to configure VXLAN connections"
  type        = bool
  default     = false
}

variable "vxlan_peers" {
  description = "Details for vxlan connections beteween fortigates"
  type        = list(map(string))
  default = [{
    external_ip   = "11.11.11.22,11.11.11.23" //you should use comma separted IPs
    remote_ip     = "10.10.30.2,10.10.30.3"   //you should use comma separted IPs
    local_ip      = "10.10.30.1"
    bgp_asn       = "65000"
    vni           = "1100"
    vxlan_port    = "private"
    route_map_in  = ""
    route_map_out = ""
  }]
}
#-----------------------------------------------------------------------------------
# Predefined variables for FMG 
# - config_fmg = false (default) 
#-----------------------------------------------------------------------------------
variable "config_fmg" {
  type    = bool
  default = false
}
variable "fmg_ip" {
  type    = string
  default = ""
}
variable "fmg_sn" {
  type    = string
  default = ""
}
variable "fmg_interface_select_method" {
  type    = string
  default = ""
}
variable "fmg_source_ip_fgt" {
  type    = string
  default = ""
}
#-----------------------------------------------------------------------------------
# Predefined variables for FAZ 
# - config_faz = false (default) 
#-----------------------------------------------------------------------------------
variable "config_faz" {
  type    = bool
  default = false
}
variable "faz_ip" {
  type    = string
  default = ""
}
variable "faz_sn" {
  type    = string
  default = ""
}
variable "faz_interface_select_method" {
  type    = string
  default = ""
}
variable "faz_source_ip_fgt" {
  type    = string
  default = ""
}
#-----------------------------------------------------------------------------------
# SDN connector
#-----------------------------------------------------------------------------------
variable "tenancy_ocid" {
  type    = string
  default = ""
}
variable "compartment_ocid" {
  type    = string
  default = ""
}
#-----------------------------------------------------------------------------------
# FGT variables
#-----------------------------------------------------------------------------------
variable "fgt_id" {
  description = "FortiGate description"
  type    = string
  default = "fgt1"
}
#-----------------------------------------------------------------------------------
variable "admin_cidr" {
  type    = string
  default = "0.0.0.0/0"
}
variable "admin_port" {
  type    = string
  default = "8443"
}
variable "api_key" {
  type    = string
  default = null
}
variable "config_extra_fgt" {
  type    = string
  default = ""
}
variable "vcn_spoke_cidrs" {
  type    = list(string)
  default = null
}
variable "fgt_ips" {
  type    = map(string)
  default = null
}
variable "fgt_subnet_cidrs" {
  type    = map(string)
  default = null
}
variable "ports" {
  type = map(string)
  default = {
    public  = "port1"
    private = "port2"
  }
}
variable "public_port" {
  type    = string
  default = "port1"
}
variable "private_port" {
  type    = string
  default = "port2"
}
variable "license_type" {
  description = "Provide the license type for FortiGate-VM Instances, either byol or payg."
  type    = string
  default = "payg"
}
variable "license_file" {
  description = "Route to your byol license file, license.lic"
  type    = string
  default = "./licenses/license.lic"
}
variable "fortiflex_token" {
  description = "FortiFlex token"
  type    = string
  default = ""
}
variable "rsa_public_key" {
  description = "SSH RSA public key for KeyPair"
  type    = string
  default = null
}

