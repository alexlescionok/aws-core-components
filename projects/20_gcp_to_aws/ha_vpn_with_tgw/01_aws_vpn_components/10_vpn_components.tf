### VPN
resource "aws_customer_gateway" "objs" {
  for_each   = local.vpn_defs
  bgp_asn    = local.gcp_asn
  ip_address = each.value["ip_address"]
  type       = "ipsec.1"
  tags = {
    Name = each.value["cgw_name"]
  }
}

resource "aws_vpn_connection" "objs" {
  for_each             = local.vpn_defs
  customer_gateway_id  = aws_customer_gateway.objs[each.key].id
  transit_gateway_id   = local.transit_gateway_id
  type                 = "ipsec.1"
  tunnel1_ike_versions = ["ikev2"]
  tunnel2_ike_versions = ["ikev2"]
  tags = {
    Name = each.value["vpn_connection_name"]
  }
}