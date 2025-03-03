###################################### Locals/Variables ######################################
locals {
  gcp_default_region = "REPLACE_ME"

  gcp_project = {
    name    = "REPLACE_ME"
    id      = "REPLACE_ME"
    network = "REPLACE_ME"
  }
}

###################################### Terraform ######################################
terraform {
  required_version = "~> 1.9"

  backend "s3" {
    bucket         = "REPLACE_ME"
    region         = "REPLACE_ME"
    key            = "REPLACE_ME"
    encrypt        = true
    dynamodb_table = "REPLACE_ME"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

###################################### Providers ######################################
provider "google" {
  region  = local.gcp_default_region
  project = local.gcp_project.id
}