variable "compartment_ocid" {
  description = "OCI compartment ID"
}

variable "tenancy_ocid" {
  description = "OCI Tenancy ID"
  type        = string
  default     = ""
}

variable "prefix" {
  description = "Resources name prefix"
  type        = string
  default     = "terraform"
}

variable "suffix" {
  description = "Resources name suffix"
  type        = string
  default     = "1"
}

variable "tags" {
  description = "Attribute for tag Enviroment"
  type        = map(any)
  default = {
    project = "terraform"
  }
}

variable "region" {
  description = "OCI region to deploy fortigate instances"
  type        = string
  default     = "eu-frankfurt-1"
}

variable "region_ad" {
  description = "OCI region Availability Domain 1"
  type        = string
  default     = "1"
}

variable "fgt_config" {
  description = "Fotigate 1 bootstrap config"
  type        = string
  default     = ""
}

variable "fgt_image_ids" {
  description = "Fortigate image IDs either BYOL or PAYG"
  type        = map(string)
  default = {
    //byol = "ocid1.image.oc1..aaaaaaaaywpjxu5763zxcu5lgsvsgy47uaxig7h4q4nsv2qqrblwxgt4pbqa" // 7.2.9 x86
    byol = "ocid1.image.oc1..aaaaaaaaqtn5zzxeq2umyspk72ge7byv4sdrmuyz2moera44ms2d3i66ge5a" // 7.4.4 x86
    //byol = "ocid1.image.oc1..aaaaaaaayemuikjhe64ns25jxggllgu7qkkrkxd6y3b664fmz3j7ugj322pa" // 7.2.6 x86
    //payg = "ocid1.image.oc1..aaaaaaaasaccoftifcf5i7db4wye5xcv24lxqfbrg2abbzczjovrkhfc54ba" // 7.2.9 x86
    payg = "ocid1.image.oc1..aaaaaaaa5gjppe75polatsasipzuv3g5x7ectgrlybocfbojr4izqhpsxega" // 7.4.4 x86
    //payg = "ocid1.image.oc1..aaaaaaaa3ipiyncshrtv5enxycafbh7qa6av7t57c4rdcuhchvfpjumm4wja" // 7.6.0 x86
  }
}

variable "instance_shape" {
  description = "Oracle instance types"
  type        = string
  default     = "VM.Standard2.4"
  // default = "VM.Standard.E4.Flex"
}

variable "volume_size" {
  description = "Default secondary disk size"
  default     = "50" //GB
}

variable "fgt_ni_0" {
  description = "Index 0 instace interface type of port"
  type        = string
  default     = "public"
}
variable "fgt_ni_1" {
  description = "Index 1 instace interface type of port"
  type        = string
  default     = "private"
}

variable "license_type" {
  description = "Provide the license type for FortiGate-VM Instances, either byol or payg"
  type        = string
  default     = "payg"
}

variable "fgt_subnet_ids" {
  description = "Fortigate subnets IDs map"
  type        = map(string)
  default     = null
}

variable "fgt_vcn_id" {
  description = "Orace VCN where deploy Fortigate instances"
  type        = string
  default     = null
}

variable "fgt_ips" {
  description = "Fortigate 1 map of IPs of each port"
  type        = map(string)
  default     = null
}

variable "fgt_vnic_ips" {
  description = "Fortigate 1 instance map of IPs of each network interface"
  type        = map(string)
  default     = null
}

variable "public_ip_lifetime" {
  description = "Type of public IPs"
  type        = string
  default     = "RESERVED"
  //or EPHEMERAL
}

variable "fgt_nsg_ids" {
  description = "Map of security groups to assign"
  type        = map(string)
  default     = null
}

variable "ocpus" {
  description = "OCI instance number of CPUs, used if type of instance is flex"
  type        = number
  default     = 4
}

variable "memory_in_gbs" {
  description = "OCI instance GBp of RAM memory, used if type of instance is flex"
  type        = number
  default     = 16
}
