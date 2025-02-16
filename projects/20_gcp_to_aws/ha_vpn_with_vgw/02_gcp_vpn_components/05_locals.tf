locals {
  data_lookups = {
    vpn_gateway          = data.terraform_remote_state.gcp_vpn_gateway.outputs
    aws_vpn_componenents = data.terraform_remote_state.aws_vpn_componenents.outputs
  }

  gcp_asn = "REPLACE_ME" # gcp_asn is set to 64550 in article
  aws_asn = "REPLACE_ME" # aws_asn is set to 64560 in article

  gcp_project_id = "REPLACE_ME" # gcp_project_id is set to my-gcp-project in article
  project_name   = "${local.gcp_project.id}-to-aws-vgw"
}