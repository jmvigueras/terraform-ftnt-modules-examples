output "id" {
  description = "Fortigate instance id"
  value       = oci_core_instance.fgt.id
}

output "public_ip" {
  description = "Fortigate public IP public interface"
  value       = oci_core_instance.fgt.public_ip
}