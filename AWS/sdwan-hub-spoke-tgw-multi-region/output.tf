#-----------------------------------------------------------------------------------------------------
# EU - EMEA HUB
#-----------------------------------------------------------------------------------------------------
output "eu_hub_ids" {
  value = module.eu_hub.fgt_list
}

output "eu_hub_ni_list" {
  value = module.eu_hub_nis.fgt_ni_list
}

output "eu_spoke_to_tgw_vm" {
  value = { for k, v in module.eu_spoke_to_tgw_vm : k => v.vm }
}
/*
output "eu_hub_vm" {
  value = module.eu_hub_vm.vm
}
*/
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
# HUB ON-PREMISES
#-----------------------------------------------------------------------------------------------------
output "eu_op_ids" {
  value = module.eu_op.fgt_list
}

output "eu_op_ni_list" {
  value = module.eu_op_nis.fgt_ni_list
}
/*
output "eu_op_vm" {
  value = module.eu_op_vm.vm
}
*/
#-----------------------------------------------------------------------------------------------------
# US - NORAM HUB
#-----------------------------------------------------------------------------------------------------
output "us_hub_ids" {
  value = module.us_hub.fgt_list
}

output "us_hub_ni_list" {
  value = module.us_hub_nis.fgt_ni_list
}

output "us_spoke_to_tgw_vm" {
  value = { for k, v in module.us_spoke_to_tgw_vm : k => v.vm }
}

/*
output "us_hub_vm" {
  value = module.us_hub_vm.vm
}
*/
#-----------------------------------------------------------------------------------------------------
# US SDWAN SPOKES
#-----------------------------------------------------------------------------------------------------
output "us_sdwan_ids" {
  value = { for k, v in module.us_sdwan : k => v.fgt_list }
}

output "us_sdwan_ni_list" {
  value = { for k, v in module.us_sdwan_nis : k => v.fgt_ni_list }
}

output "us_sdwan_vm" {
  value = { for k, v in module.us_sdwan_vm : k => v.vm }
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