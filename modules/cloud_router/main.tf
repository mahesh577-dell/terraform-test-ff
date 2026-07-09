resource "google_compute_router" "router" {
  project     = var.project_id
  name        = var.router_name
  region      = var.region
  network     = var.vpc_self_link
  description = "Cloud Router enables NAT and future VPN to AWS"

  bgp {
    asn            = var.bgp_asn
    advertise_mode = "DEFAULT"
  }
}
