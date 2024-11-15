output "fgts" {
  value = { for k, v in module.fgt :
    "fgt${k + 1}" => {
      fgt_pass = v.id
      fgt_mgmt = "https://${v.public_ip}:${local.admin_port}"
    }
  }
}

output "spoke_vm_iperf_clients" {
  value = { for k, v in module.spoke_vm_iperf_clients : "iperf-client${k + 1}" => v.vm["public_ip"] }
}
output "spoke_vm_iperf_servers" {
  value = { for k, v in module.spoke_vm_iperf_servers : "iperf-server${k + 1}" => v.vm["public_ip"] }
}