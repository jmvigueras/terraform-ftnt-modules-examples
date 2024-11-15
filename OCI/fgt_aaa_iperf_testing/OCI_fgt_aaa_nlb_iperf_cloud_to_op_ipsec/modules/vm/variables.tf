variable "compartment_ocid" {}

variable "region" {
  type    = string
  default = "eu-frankfurt-1"
}

variable "region_ad" {
  type    = string
  default = "1"
}

variable "prefix" {
  description = "OCI resources prefix"
  type    = string
  default = "terraform"
}

variable "sufix" {
  type    = string
  default = "1"
}

variable "tags" {
  description = "Resouce Tags"
  type        = map(string)
  default = {}
}

variable "shape" {
  type    = string
  default = "VM.Standard.A1.Flex"
}

variable "ocpus" {
  type    = number
  default = 1
}

variable "memory_in_gbs" {
  type    = number
  default = 2
}

variable "authorized_keys" {
  description = "SSH RSA public key for KeyPair if not exists"
  type    = list(string)
  default = null
}

variable "subnet_id" {
  type    = string
  default = null
}

variable "user_data" {
  description = "VM user-data"
  type    = string
  default = null
}
