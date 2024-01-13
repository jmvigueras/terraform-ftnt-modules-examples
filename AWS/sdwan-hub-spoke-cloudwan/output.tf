#-----------------------------------------------------------------------------------------------------
# EU - EMEA HUB
#-----------------------------------------------------------------------------------------------------
output "eu_hub_ids" {
  value = module.eu_hub.fgt_list
}

output "eu_hub_ni_list" {
  value = module.eu_hub_nis.fgt_ni_list
}

output "eu_hub_vm" {
  value = module.eu_hub_vm.vm
}

#-----------------------------------------------------------------------------------------------------
# EU SDWAN SPOKES
#-----------------------------------------------------------------------------------------------------
output "eu_sdwan_ids" {
  value = { for k, v in module.eu_sdwan : k => v.fgt_list }
}

output "eu_sdwan_ni_list" {
  value = { for k, v in module.eu_sdwan_nis : k => v.fgt_ni_list }
}

output "eu_sdwan_vm" {
  value = { for k, v in module.eu_sdwan_vm : k => v.vm }
}

#-----------------------------------------------------------------------------------------------------
# EU CORENET SPOKES
#-----------------------------------------------------------------------------------------------------
output "eu_spoke_to_core_net_vm" {
  value = { for k, v in module.eu_spoke_to_core_net_vm : k => v.vm }
}


/*
#-------------------------------
# Debugging 
#-------------------------------
output "eu_hub_ni_list" {
  value = module.eu_hub_nis.ni_list
}
output "debugs" {
  value = { for k, v in module.eu_hub_config : k => v.debugs }
}
output "eu_sdwan_ni_list" {
  value = { for k, v in module.eu_sdwan_nis : k => v.ni_list }
}

output "eu_hub_public_eips" {
  value = local.eu_hub_public_eips
}
*/