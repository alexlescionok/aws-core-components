### Virtual Private Gateway
resource "aws_vpn_gateway" "this" {
  vpc_id          = "REPLACE_ME"
  amazon_side_asn = local.aws_asn
}

locals {
  route_table_propagations = [
    "REPLACE_ME",
    # further route table IDs
  ]
}
resource "aws_vpn_gateway_route_propagation" "objs" {
  for_each       = toset(local.route_table_propagations)
  vpn_gateway_id = aws_vpn_gateway.this.id
  route_table_id = each.key
}

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
  vpn_gateway_id       = aws_vpn_gateway.this.id
  type                 = "ipsec.1"
  tunnel1_ike_versions = "ikev2"
  tunnel2_ike_versions = "ikev2"
  tags = {
    Name = each.value["vpn_connection_name"]
  }
}