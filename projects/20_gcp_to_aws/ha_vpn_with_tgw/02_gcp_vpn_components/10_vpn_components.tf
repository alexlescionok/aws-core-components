locals {
  /*
  HA VPN Gateway interfaces are mapped in the following order to AWS S2S VPN Connections:
  - HA VPN Gateway interfaces 0 -> AWS S2S VPN Connection 1 tunnel 1
  - HA VPN Gateway interfaces 0 -> AWS S2S VPN Connection 1 tunnel 2
  - HA VPN Gateway interfaces 1 -> AWS S2S VPN Connection 2 tunnel 1
  - HA VPN Gateway interfaces 1 -> AWS S2S VPN Connection 2 tunnel 2
  See here for further information: https://cloud.google.com/network-connectivity/docs/vpn/how-to/connect-ha-vpn-aws-peer-gateway#havpn-aws-peer
  
  Cloud Router will dynamically provision routes to the dedicated TGW ; if there are 4 tunnels, it will provision 4 routes - 2 to per Cloud VPN Gateway interface
  Cloud Router does not create a new route if a tunnel goes down. For example, if tunnel 0 goes down, then only routes going to tunnels 1, 2, and 3 will remain.
  */
  tunnels = {
    0 = {
      shared_secret         = local.data_lookups["aws_vpn_componenents"]["vpn_connection_sensitive_objs"]["cgw_0"]["tunnel1_preshared_key"]
      ip_range              = "${local.data_lookups["aws_vpn_componenents"]["vpn_connection_objs"]["cgw_0"]["tunnel1_cgw_inside_address"]}/30"
      peer_ip_address       = local.data_lookups["aws_vpn_componenents"]["vpn_connection_objs"]["cgw_0"]["tunnel1_vgw_inside_address"]
      ip_address            = local.data_lookups["aws_vpn_componenents"]["vpn_connection_objs"]["cgw_0"]["tunnel1_address"]
      vpn_gateway_interface = 0
    }
    1 = {
      shared_secret         = local.data_lookups["aws_vpn_componenents"]["vpn_connection_sensitive_objs"]["cgw_0"]["tunnel2_preshared_key"]
      ip_range              = "${local.data_lookups["aws_vpn_componenents"]["vpn_connection_objs"]["cgw_0"]["tunnel2_cgw_inside_address"]}/30"
      peer_ip_address       = local.data_lookups["aws_vpn_componenents"]["vpn_connection_objs"]["cgw_0"]["tunnel2_vgw_inside_address"]
      ip_address            = local.data_lookups["aws_vpn_componenents"]["vpn_connection_objs"]["cgw_0"]["tunnel2_address"]
      vpn_gateway_interface = 0
    }
    2 = {
      shared_secret         = local.data_lookups["aws_vpn_componenents"]["vpn_connection_sensitive_objs"]["cgw_1"]["tunnel1_preshared_key"]
      ip_range              = "${local.data_lookups["aws_vpn_componenents"]["vpn_connection_objs"]["cgw_1"]["tunnel1_cgw_inside_address"]}/30"
      peer_ip_address       = local.data_lookups["aws_vpn_componenents"]["vpn_connection_objs"]["cgw_1"]["tunnel1_vgw_inside_address"]
      ip_address            = local.data_lookups["aws_vpn_componenents"]["vpn_connection_objs"]["cgw_1"]["tunnel1_address"]
      vpn_gateway_interface = 1
    }
    3 = {
      shared_secret         = local.data_lookups["aws_vpn_componenents"]["vpn_connection_sensitive_objs"]["cgw_1"]["tunnel2_preshared_key"]
      ip_range              = "${local.data_lookups["aws_vpn_componenents"]["vpn_connection_objs"]["cgw_1"]["tunnel2_cgw_inside_address"]}/30"
      peer_ip_address       = local.data_lookups["aws_vpn_componenents"]["vpn_connection_objs"]["cgw_1"]["tunnel2_vgw_inside_address"]
      ip_address            = local.data_lookups["aws_vpn_componenents"]["vpn_connection_objs"]["cgw_1"]["tunnel2_address"]
      vpn_gateway_interface = 1
    }
  }
}

/*
Set advertise_mode to "DEFAULT" as you are only connecting 1 VPC Network to AWS
Set it to "CUSTOM" if connecting multiple networks; see here: https://cloud.google.com/network-connectivity/docs/router/how-to/advertising-custom-ip
*/
resource "google_compute_router" "this" {
  name    = "${local.project_name}-cloud-router"
  network = "default"
  region  = local.gcp_default_region
  bgp {
    asn            = local.gcp_asn
    advertise_mode = "DEFAULT"
  }
}

/*
Achieving 99.99% availability: https://cloud.google.com/network-connectivity/docs/vpn/concepts/topologies#ensuring-ha-peer
From GCP:
"To meet the 99.99% availability SLA on the Google Cloud side, there must be a tunnel from each of the two interfaces on the HA VPN gateway to the corresponding interfaces on the peer gateway."
As Customer Gateway can only specify 1 external IP (taken from 1 of the interface on the GCP-side), you need to create 2 Customer Gateways and 2 Site-to-Site VPNs to achieve 99.99% availability

"Configuring only one tunnel from a single HA VPN interface to a single interface on the peer gateway doesn't provide enough redundancy to meet the availability SLA because there is an unused interface on the HA VPN gateway, which does not have a tunnel configured on it."
Therefore if you only configure one tunnel, you will not have 99.99% availability AND the unused tunnel in the Site-to-Site VPN Connection will display as "Down"
*/
resource "google_compute_external_vpn_gateway" "this" {
  name            = "${local.project_name}-external-gateway"
  redundancy_type = "FOUR_IPS_REDUNDANCY"
  description     = "An externally managed VPN gateway"
  dynamic "interface" {
    for_each = { for k, v in local.tunnels : k => merge(v, { id = k }) }
    content {
      id         = interface.value["id"]
      ip_address = interface.value["ip_address"]
    }
  }
}

resource "google_compute_vpn_tunnel" "objs" {
  for_each                        = local.tunnels
  name                            = "${local.project_name}-ha-vpn-tunnel-${each.key}"
  vpn_gateway                     = local.data_lookups["vpn_gateway"]["ha_vpn_gateway"]["id"]
  peer_external_gateway           = google_compute_external_vpn_gateway.this.id
  peer_external_gateway_interface = each.key
  shared_secret                   = each.value["shared_secret"]
  router                          = google_compute_router.this.id
  vpn_gateway_interface           = each.value["vpn_gateway_interface"]
  region                          = local.gcp_default_region
  ike_version                     = 2
}

resource "google_compute_router_interface" "objs" {
  for_each   = local.tunnels
  name       = "${local.project_name}-router-interface-${each.key}"
  router     = google_compute_router.this.name
  region     = local.gcp_default_region
  ip_range   = each.value["ip_range"]
  vpn_tunnel = "${local.project_name}-ha-vpn-tunnel-${each.key}"
  depends_on = [google_compute_vpn_tunnel.objs]
}

resource "google_compute_router_peer" "objs" {
  for_each        = local.tunnels
  name            = "${local.project_name}-router-peer-${each.key}"
  router          = google_compute_router.this.name
  region          = local.gcp_default_region
  peer_ip_address = each.value["peer_ip_address"]
  peer_asn        = local.aws_asn
  interface       = google_compute_router_interface.objs[each.key].name

  advertise_mode = "DEFAULT"
}