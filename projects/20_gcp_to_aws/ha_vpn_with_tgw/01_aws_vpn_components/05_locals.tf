locals {
  data_lookups = {
    gcp_vpn_gateway = data.terraform_remote_state.gcp_vpn_gateway.outputs
  }

  gcp_asn = "REPLACE_ME" # gcp_asn is set to 64550 in article
  aws_asn = "REPLACE_ME" # aws_asn is set to 64512 in article

  gcp_project = {
    name         = "REPLACE_ME"
    id           = "REPLACE_ME"
    network_cidr = "REPLACE_ME"
  }

  project_name = "${local.gcp_project.id}-to-aws-tgw"

  transit_gateway_id = "REPLACE_ME"

  vpn_defs = {
    cgw_0 = {
      cgw_name            = "${local.project_name}-cgw-vpn-interface-0"
      vpn_connection_name = "${local.project_name}-connection-vpn-interface-0"
      ip_address          = local.data_lookups.gcp_vpn_gateway.ha_vpn_gateway.vpn_inteface_external_ip_0
    }
    cgw_1 = {
      cgw_name            = "${local.project_name}-cgw-vpn-interface-1"
      vpn_connection_name = "${local.project_name}-connection-vpn-interface-1"
      ip_address          = local.data_lookups.gcp_vpn_gateway.ha_vpn_gateway.vpn_inteface_external_ip_1
    }
  }
}