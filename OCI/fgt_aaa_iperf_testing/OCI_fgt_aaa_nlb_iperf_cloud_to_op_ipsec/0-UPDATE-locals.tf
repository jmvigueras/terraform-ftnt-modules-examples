#-----------------------------------------------------------------------------------------------------
# General variables
#-----------------------------------------------------------------------------------------------------
locals {
  prefix = "ipsec"

  admin_cidr   = "0.0.0.0/0"
  admin_port   = "8443"
  license_type = "payg"

  bgp_asn = "65000"
}
#-----------------------------------------------------------------------------------------------------
# HUB OCI variables
#-----------------------------------------------------------------------------------------------------
locals {
  hub_oci_shape = "VM.Standard2.16" // Intel 16 OCPU
  hub_oci_image_ids = {
    "payg" = "ocid1.image.oc1..aaaaaaaarmoubcdil5nhouymlsgbvdxyzmxcfxnrogejehwtmfppwbski2eq" // 7.4.4 PAYG 16 OCPU
  }

  hub_oci_cidr         = "172.16.0.0/12"
  hub_oci_vcn_cidr     = "172.20.0.0/24"
  hub_oci_spokes_cidrs = ["172.20.100.0/24"]

  hub_oci_fgsp_cluster_number = 3
}
#-----------------------------------------------------------------------------------------------------
# HUB OP variables
#-----------------------------------------------------------------------------------------------------
locals {
  hub_op_shape  = "VM.Standard.E4.Flex" // AMD Flex
  hub_op_ocpu   = 24
  hub_op_memory = 384
  hub_op_image_ids = {
    "payg" = "ocid1.image.oc1..aaaaaaaadx2vibovdtqd5b5hpvnrkbwkplqdy52kq5o246ggy3m7p3lveppq" // 7.4.4 PAYG 24 OCPU
  }

  hub_op_cidr     = "192.168.0.0/16"
  hub_op_vcn_cidr = "192.168.0.0/24"
}
#-----------------------------------------------------------------------------------------------------
# IPERF test variables
#-----------------------------------------------------------------------------------------------------
locals {
  iperf_vms       = 20 //number of linux vm performing IPERF between sites
  iperf_parallels = 50 //number of parallels iperf peer test
  iperf_loop      = 60 //number of seconds to repeat the iperf test
  iperf_window    = "256K"

  number_ocpus  = 5
  memory_in_gbs = 6
}