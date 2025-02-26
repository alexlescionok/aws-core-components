# Route to TGW - note, the TGW VPC attachment must already be provisioned for the route to be successfully created
locals {
  route_tables = [
    "REPLACE_ME",
    # further route table IDs
  ]
}

resource "aws_route" "objs" {
  for_each               = toset(local.route_tables)
  route_table_id         = each.key
  destination_cidr_block = local.gcp_project.network_cidr
  transit_gateway_id     = local.transit_gateway_id
}
