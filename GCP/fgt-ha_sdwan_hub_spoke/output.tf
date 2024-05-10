output "hub" {
  value = {
    fgt-1_mgmt   = "https://${module.hub.fgt_active_eip_mgmt}:${local.admin_port}"
    fgt-1_pass   = module.hub.fgt_active_id
    fgt-2_mgmt   = module.hub.fgt_passive_eip_mgmt
    fgt-2_pass   = module.hub.fgt_passive_id
    fgt-1_public = module.hub.fgt_active_eip_public
  }
}

output "spokes" {
  value = [for k, v in module.spoke_fgt : {
    fgt_mgmt = "https://${v.fgt_eip_public}:${local.admin_port}"
    fgt_pass = v.fgt_id
    }
  ]
}