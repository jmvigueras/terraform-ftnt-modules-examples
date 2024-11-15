output "hub_oci" {
  value = { for k, v in module.hub_oci :
    "fgt${k + 1}" => {
      pass_id  = v.id
      fgt_mgmt = "https://${v.public_ip}:${local.admin_port}"
    }
  }
}

output "hub_op" {
  value = {
    pass_id   = module.hub_op.fgt_1_id
    fgt1_mgmt = "https://${module.hub_op.fgt_1_public_ip_mgmt}:${local.admin_port}"
    fgt2_mgmt = "https://${module.hub_op.fgt_2_public_ip_mgmt}:${local.admin_port}"
  }
}

output "spoke_vm_iperf_clients" {
  value = { for k, v in module.spoke_vm_iperf_clients : "iperf-client${k + 1}" => v.vm["public_ip"] }
}
output "spoke_vm_iperf_servers" {
  value = { for k, v in module.spoke_vm_iperf_servers : "iperf-server${k + 1}" => v.vm["public_ip"] }
}
