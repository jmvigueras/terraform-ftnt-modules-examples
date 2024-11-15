#-----------------------------------------------------------------------
# Deploy Iperf3 servers and clients
#-----------------------------------------------------------------------
locals {
  spoke_vm_iperf_servers = [
    for i in range(0, local.iperf_vms) :
    templatefile("./templates/iperf_server.sh", {})
  ]
  spoke_vm_iperf_clients = [
    for i in range(0, local.iperf_vms) :
    templatefile("./templates/iperf_client.sh", {
      server_ip = module.spoke_vm_iperf_servers[i].vm["private_ip"]
      parallels = local.iperf_parallels
      loop_time = local.iperf_loop
      window    = local.iperf_window
      }
    )
  ]
}
// Create iperf3 servers
module "spoke_vm_iperf_servers" {
  source = "./modules/vm"

  count = local.iperf_vms

  compartment_ocid = var.compartment_ocid

  prefix = "${local.prefix}-spoke1"
  sufix  = "s${count.index + 1}"

  region_ad       = tostring(count.index % 2 + 1) // deploy half of VMs in each AD
  subnet_id       = module.spoke_vcns[0].subnet_ids["vm"]
  authorized_keys = local.authorized_keys

  ocpus         = local.number_ocpus
  memory_in_gbs = local.memory_in_gbs

  user_data = local.spoke_vm_iperf_servers[count.index]
}
// Create iperf3 clients
module "spoke_vm_iperf_clients" {
  source = "./modules/vm"

  count = local.iperf_vms

  compartment_ocid = var.compartment_ocid

  prefix = "${local.prefix}-spoke2"
  sufix  = "c${count.index + 1}"

  region_ad       = tostring(count.index % 2 + 1) // deploy half of VMs in each AD
  subnet_id       = module.spoke_vcns[1].subnet_ids["vm"]
  authorized_keys = local.authorized_keys

  ocpus         = local.number_ocpus
  memory_in_gbs = local.memory_in_gbs

  user_data = local.spoke_vm_iperf_clients[count.index]
}
