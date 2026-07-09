resource "google_compute_subnetwork" "subnet" {
  for_each                 = var.subnets
  name                     = each.key
  ip_cidr_range            = each.value.cidr
  region                   = each.value.region
  network                  = var.vpc_name
  project                  = var.project_id
  description              = lookup(each.value, "description", "")
  private_ip_google_access = lookup(each.value, "private_ip_google_access", false)

  dynamic "secondary_ip_range" {
    for_each = lookup(each.value, "secondary_ranges", [])
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  log_config {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = var.flow_sampling
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
