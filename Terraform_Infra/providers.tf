terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.47.0"
    }
  }



  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/57372801/terraform/state/eks_state"
    lock_address   = "https://gitlab.com/api/v4/projects/57372801/terraform/state/eks_state/lock"
    unlock_address = "https://gitlab.com/api/v4/projects/57372801/terraform/state/eks_state/lock"
    username       = "Nevii"
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
    }
  
}
provider "aws" {
  region = "eu-west-3"
}