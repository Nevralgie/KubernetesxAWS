# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {

  # cloud {
  #   workspaces {
  #     name = "learn-terraform-eks"
  #   }
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.47.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.4"
    }
  }

  required_version = "~> 1.3"
  
  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/58336204/terraform/state/default"
    lock_address   = "https://gitlab.com/api/v4/projects/58336204/terraform/state/default/lock"
    unlock_address = "https://gitlab.com/api/v4/projects/58336204/terraform/state/default/lock"
    username       = "Nevii"
    password       = "glpat-Y2Qz-Qm4ksNbprNPWnzK"
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
    }
  
  
}

