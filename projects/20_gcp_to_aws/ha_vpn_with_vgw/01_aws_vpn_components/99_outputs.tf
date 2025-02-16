output "vpn_connection_objs" {
  value = {
    for obj_key, obj_value in local.vpn_defs
    : obj_key => {
      for attribute_key, attribute_value in aws_vpn_connection.objs[obj_key]
      : attribute_key => attribute_value
      if contains([
        "tunnel1_address",
        "tunnel2_address",
        "tunnel1_cgw_inside_address",
        "tunnel2_cgw_inside_address",
        "tunnel1_vgw_inside_address",
        "tunnel2_vgw_inside_address",
      ], attribute_key)
    }
  }
}

output "vpn_connection_sensitive_objs" {
  value = {
    for obj_key, obj_value in local.vpn_defs
    : obj_key => {
      for attribute_key, attribute_value in aws_vpn_connection.objs[obj_key]
      : attribute_key => attribute_value
      if contains(["tunnel1_preshared_key", "tunnel2_preshared_key"], attribute_key)
    }
  }
  sensitive = true
}

output "customer_gateway_objs" {
  value = {
    for obj_key, obj_value in local.vpn_defs
    : obj_key => {
      for attribute_key, attribute_value in aws_customer_gateway.objs[obj_key]
      : attribute_key => attribute_value
      if contains(["ip_address"], attribute_key)
    }
  }
}