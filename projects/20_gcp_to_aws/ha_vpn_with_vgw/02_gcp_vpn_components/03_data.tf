# Outputs from ../00_gcp_vpn_gateway
data "terraform_remote_state" "gcp_vpn_gateway" {
  backend = "s3"

  config = {
    bucket  = "REPLACE_ME"
    region  = "REPLACE_ME"
    key     = "REPLACE_ME"
    encrypt = true
  }
}

# Outputs from ../01_aws_vpn_components
data "terraform_remote_state" "aws_vpn_componenents" {
  backend = "s3"

  config = {
    bucket  = "REPLACE_ME"
    region  = "REPLACE_ME"
    key     = "REPLACE_ME"
    encrypt = true
  }
}