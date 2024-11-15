#-----------------------------------------------------------------------------------------------------
# Deploy a Fortinet HUB and SPOKE SDWAN topology
# - VPN FortiGate HUB on AWS
# - VPC spokes attached to TGW
# - FortiGate SDWAN spokes
# - Test linux instance VMs
#-----------------------------------------------------------------------------------------------------
module "fgt-hub-spoke" {
  source  = "jmvigueras/ftnt-aws-modules/aws//examples/middle_tgw-fgt-ha-sdwan-hub-spoke"
  version = "0.0.8"

  access_key = ""
  secret_key = ""
}

output "hub_mgmt" {
  value = module.fgt-hub-spoke.hub_mgmt
}
output "sdwan_mgmt" {
  value = module.fgt-hub-spoke.sdwan_mgmt
}
output "sdwan_vms" {
  value = module.fgt-hub-spoke.sdwan_vms
}
output "spoke_vms" {
  value = module.fgt-hub-spoke.spoke_vms
}