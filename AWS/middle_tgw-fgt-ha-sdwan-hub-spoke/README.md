# Example: Forigate deployment SDWAN HUB and SPOKE on AWS

This is an example of how to deploy a complete setup of a SDWAN HUB on AWS and SPOKEs, including VPC spokes to a TGW and remote spokes to SDWAN. 

The code point to modules in a Terraform registry [ftnt-aws-modules](https://registry.terraform.io/modules/jmvigueras/ftnt-aws-modules/aws/latest)

## Deployment Overview

Modules code uses variables defined at [0_UPDATE-locals.tf](./0_UPDATE-locals.tf)

```hcl
module "fgt-hub-spoke" {
  source  = "jmvigueras/ftnt-aws-modules/aws//examples/middle_tgw-fgt-ha-sdwan-hub-spoke"
  version = "0.0.8"

  access_key = ""
  secret_key = ""

  
}
```

## Requirements
* [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) >= 1.5.0
* Check particulars requiriments for each deployment (AWS) 

## Deployment

# Support
This a personal repository with goal of testing and demo Fortinet solutions on the Cloud. No support is provided and must be used by your own responsability. Cloud Providers will charge for this deployments, please take it in count before proceed.


