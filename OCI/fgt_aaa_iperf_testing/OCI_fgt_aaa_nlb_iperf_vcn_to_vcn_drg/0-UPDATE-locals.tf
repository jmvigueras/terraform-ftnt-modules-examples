#-----------------------------------------------------------------------------------------------------
# General variables
#-----------------------------------------------------------------------------------------------------
locals {
  prefix = "drg"

  admin_cidr   = "0.0.0.0/0"
  admin_port   = "8443"
  license_type = "payg"

  vcn_cidr     = "172.20.0.0/24"
  spokes_cidrs = ["172.20.100.0/24", "172.20.150.0/24"]
}
#-----------------------------------------------------------------------------------------------------
# FGT FGSP variables
#-----------------------------------------------------------------------------------------------------
locals {
  fgt_shape = "VM.Standard2.16" // Intel 16 OCPU
  fgt_image_ids = {
    "payg" = "ocid1.image.oc1..aaaaaaaarmoubcdil5nhouymlsgbvdxyzmxcfxnrogejehwtmfppwbski2eq" // 7.4.4 PAYG 16 OCPU
  }

  fgsp_cluster_number = 3
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