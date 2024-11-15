# Configure the Oracle Cloud Infrastructure provider with a version constraint
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.12"
    }
  }
}

provider "oci" {
  //tenancy_ocid     = var.tenancy_ocid
  //user_ocid        = var.user_ocid
  //fingerprint      = var.fingerprint
  //private_key_path = var.private_key_path
  region = var.region
}
