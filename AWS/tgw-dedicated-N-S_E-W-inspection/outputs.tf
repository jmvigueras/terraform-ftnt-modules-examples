#-----------------------------------------------------------------------------------------------------
# Outputs
#-----------------------------------------------------------------------------------------------------
output "ew_fgt_ids" {
  value = module.ew_fgt.fgt_list
}

output "ew_fgt_ni_list" {
  value = module.ew_fgt_nis.fgt_ni_list
}

output "ns_fgt_ids" {
  value = module.ns_fgt.fgt_list
}

output "ns_fgt_ni_list" {
  value = module.ns_fgt_nis.fgt_ni_list
}

output "vpc_spokes_vm" {
  value = { for k, v in module.vpc_spokes_vm : k => v.vm }
}

/*
#-------------------------------
# Debugging 
#-------------------------------
output "fgt_ni_list" {
  value = module.fgt_nis.fgt_ni_list
}

output "fgt_ni_ports_config" {
  value = module.fgt_nis.fgt_ports_config
}

output "ni_list" {
  value = module.fgt_nis.ni_list
}
*/