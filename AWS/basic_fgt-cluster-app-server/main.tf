locals {
  # General variables
  prefix = "fgt-cluster-k8s"
}

#--------------------------------------------------------------------------------------------------------------
# FGT Cluster module example
# - 1 FortiGate cluster FGCP in 2 AZ
#--------------------------------------------------------------------------------------------------------------
module "fgt-cluster" {
  source  = "jmvigueras/ftnt-aws-modules/aws//examples/basic_fgt-cluster"
  version = "0.0.12"

  prefix = local.prefix

  region = "eu-west-1"
  azs    = ["eu-west-1a", "eu-west-1b"]

  fgt_build    = "build2731"
  license_type = "payg"

  fgt_number_peer_az = 1
  fgt_cluster_type   = "fgcp"

  public_subnet_names_extra  = ["bastion"]
  private_subnet_names_extra = ["protected"]
}

#--------------------------------------------------------------------------------------------------------------
# K8S server
# - Two applications deployed
#--------------------------------------------------------------------------------------------------------------
module "k8s" {
  source  = "jmvigueras/ftnt-aws-modules/aws//modules/vm"
  version = "0.0.12"

  prefix        = local.prefix
  keypair       = module.fgt-cluster.keypair_name
  instance_type = "t3.2xlarge"

  user_data = local.k8s_user_data

  subnet_id       = module.fgt-cluster.subnet_ids["az1"]["bastion"]
  subnet_cidr     = module.fgt-cluster.subnet_cidrs["az1"]["bastion"]
  security_groups = [module.fgt-cluster.sg_ids["default"]]
}

output "fgt" {
  value = module.fgt-cluster.fgt
}

output "k8s" {
  value = module.k8s.vm
}

locals {
  # K8S configuration and APP deployment
  k8s_deployment = templatefile("./template/k8s-dvwa-swagger.yaml", {
      dvwa_nodeport    = "31000"
      swagger_nodeport = "31001"
      swagger_host     = element(module.fgt-cluster.fgt_ni_list["az1.fgt1"].public_eips, 0)
      swagger_url      = "http://${element(module.fgt-cluster.fgt_ni_list["az1.fgt1"].public_eips, 0)}:31001"
    }
  )
  k8s_user_data = templatefile("./template/k8s.sh", {
      k8s_version    = "1.31"
      linux_user     = "ubuntu"
      k8s_deployment = local.k8s_deployment
    }
  )
}
