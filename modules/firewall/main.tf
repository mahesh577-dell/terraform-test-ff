# ═══════════════════════════════════════════════════════════════
# MODULE: Firewall
# AWS EQUIVALENT: AWS Security Groups + NACLs
#
# RULES (in priority order):
# 1. allow-internal    → VMs talk to each other inside VPC
# 2. allow-health-check→ GCP Load Balancer can check app health
# 3. allow-ssh-iap     → SSH ONLY via Google IAP (no 0.0.0.0/0!)
# 4. allow-http-https  → Port 80/443 open to internet (tagged VMs)
# 5. deny-all-ingress  → Block EVERYTHING else (default deny)
# 6. allow-all-egress  → All outbound traffic allowed
#
# SECURITY NOTE:
# SSH is restricted to IAP range (35.235.240.0/20)
# This means SSH only works via:
# gcloud compute ssh INSTANCE --tunnel-through-iap
# No direct public SSH allowed!
# ═══════════════════════════════════════════════════════════════

# 1. Allow internal VPC traffic
# All VMs in same VPC can talk to each other freely
resource "google_compute_firewall" "allow_internal" {
  project     = var.project_id
  name        = "${var.name_prefix}-allow-internal"
  network     = var.vpc_name
  description = "Allow all traffic between VMs within VPC"
  priority    = 1000
  direction   = "INGRESS"
  allow { protocol = "tcp" }
  allow { protocol = "udp" }
  allow { protocol = "icmp" }
  source_ranges = [var.vpc_cidr]  # Only from within this VPC
}

# 2. Allow GCP Load Balancer health checks
# Without this, Load Balancer thinks all backends are unhealthy
resource "google_compute_firewall" "allow_health_check" {
  project     = var.project_id
  name        = "${var.name_prefix}-allow-health-check"
  network     = var.vpc_name
  description = "Allow GCP Load Balancer health checks — required for LB to work"
  priority    = 1000
  direction   = "INGRESS"
  allow { protocol = "tcp" }
  # These are Google's official health check IP ranges
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}

# 3. Allow SSH ONLY via IAP (Identity-Aware Proxy)
# Much more secure than opening port 22 to 0.0.0.0/0
# Developers use: gcloud compute ssh VM --tunnel-through-iap
resource "google_compute_firewall" "allow_ssh_iap" {
  project     = var.project_id
  name        = "${var.name_prefix}-allow-ssh-iap"
  network     = var.vpc_name
  description = "Allow SSH only via Google IAP — no public SSH!"
  priority    = 1000
  direction   = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]  # Google IAP range only
}

# 4. Allow HTTP/HTTPS from internet
# Only applies to VMs tagged with http-server or https-server
# Not all VMs — only public-facing ones
resource "google_compute_firewall" "allow_http_https" {
  project     = var.project_id
  name        = "${var.name_prefix}-allow-http-https"
  network     = var.vpc_name
  description = "Allow HTTP/HTTPS from internet to tagged VMs only"
  priority    = 1000
  direction   = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "https-server"]  # Tagged VMs only!
}

# 5. Deny all other ingress — DEFAULT DENY
# Everything not explicitly allowed above is blocked
# Low priority (65534) means it applies last
resource "google_compute_firewall" "deny_all_ingress" {
  project     = var.project_id
  name        = "${var.name_prefix}-deny-all-ingress"
  network     = var.vpc_name
  description = "Deny all other ingress — security default"
  priority    = 65534
  direction   = "INGRESS"
  deny { protocol = "all" }
  source_ranges = ["0.0.0.0/0"]
}

# 6. Allow all outbound traffic
# VMs can reach internet (via NAT), Google APIs, other services
resource "google_compute_firewall" "allow_all_egress" {
  project     = var.project_id
  name        = "${var.name_prefix}-allow-all-egress"
  network     = var.vpc_name
  description = "Allow all outbound traffic from VMs"
  priority    = 1000
  direction   = "EGRESS"
  allow { protocol = "all" }
  destination_ranges = ["0.0.0.0/0"]
}
