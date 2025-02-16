resource "google_compute_ha_vpn_gateway" "this" {
  region  = local.gcp_default_region
  name    = "${local.project_name}-ha-vpn"
  network = "REPLACE_ME"
}