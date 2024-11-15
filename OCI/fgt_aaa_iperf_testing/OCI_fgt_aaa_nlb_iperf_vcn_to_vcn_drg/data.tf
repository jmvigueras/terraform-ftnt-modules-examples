locals {
  fgt_subnet_cidrs = module.fgt_vcn.fgt_subnet_cidrs
  subnet_cidr_host = 5
  # Map of ips of each FGSP cluster members
  fgsp_member_ips = { for i in range(0, local.fgsp_cluster_number) :
    i => cidrhost(local.fgt_subnet_cidrs["private"], local.subnet_cidr_host + i)
  }
  # Map of IPs for each fortigate
  fgt_ips = { for i in range(0, local.fgsp_cluster_number) : i => {
    "public"  = cidrhost(local.fgt_subnet_cidrs["public"], local.subnet_cidr_host + i),
    "private" = cidrhost(local.fgt_subnet_cidrs["private"], local.subnet_cidr_host + i)
    }
  }
}