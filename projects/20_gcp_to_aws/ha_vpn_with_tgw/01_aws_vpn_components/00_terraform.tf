locals {
  default_region = "REPLACE_ME"
  default_tags = {
    /*
    Default tags you wish to apply across all resources provisioned by terraform, for example:
    environment = "production"
    project     = "core-components"
    */
  }
}

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
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                   = local.default_region
  shared_config_files      = ["$HOME/.aws/config"]
  shared_credentials_files = ["$HOME/.aws/credentials"]
  profile                  = "REPLACE_ME"
  default_tags {
    tags = local.default_tags
  }
}