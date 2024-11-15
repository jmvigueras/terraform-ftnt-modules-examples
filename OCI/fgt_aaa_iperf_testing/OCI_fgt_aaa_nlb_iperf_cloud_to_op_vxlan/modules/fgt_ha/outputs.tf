output "fgt_1_id" {
  description = "Fortigate 1 instance id"
  value       = oci_core_instance.fgt_1.id
}
output "fgt_1_public_ip_mgmt" {
  description = "Fortigate 1 public IP management interface"
  value       = oci_core_instance.fgt_1.public_ip
}
output "fgt_1_public_ip_public" {
  description = "Fortigate 1 public IP public interface"
  value       = oci_core_public_ip.fgt_1_vnic_public_ip_sec.ip_address
}
output "fgt_vcn_rt_to_fgt_id" {
  description = "Route table ID created for bastion subnet in Fortigate VCN"
  value       = oci_core_route_table.rt_to_fgt.id
}

/*
output "fgt_2_id" {
  description = "Fortigate 2 instance id"
  value       = oci_core_instance.fgt_2.id
}
output "fgt_2_public_ip_mgmt" {
  description = "Fortigate 2 public IP management interface"
  value       = oci_core_instance.fgt_2.public_ip
}
*/

output "fgt_2_id" {
  description = "Fortigate 2 instance id"
  value       = ""
}
output "fgt_2_public_ip_mgmt" {
  description = "Fortigate 2 public IP management interface"
  value       = ""
}