output "ha_vpn_gateway" {
  value = {
    id                         = google_compute_ha_vpn_gateway.this.id
    vpn_inteface_external_ip_0 = google_compute_ha_vpn_gateway.this.vpn_interfaces[0].ip_address
    vpn_inteface_external_ip_1 = google_compute_ha_vpn_gateway.this.vpn_interfaces[1].ip_address
  }
}