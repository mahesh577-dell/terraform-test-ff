locals {
  common_labels = {
    environment = "dev"
    product     = "tms"
    project     = "freightfox"
    managed_by  = "terraform"
    owner       = "ankercloud"
  }
}

module "vpc" {
  source     = "../../modules/networking/vpc"
  project_id = var.project_id
  vpc_name   = var.vpc_name
}

module "subnets" {
  source        = "../../modules/networking/subnet"
  project_id    = var.project_id
  vpc_name      = module.vpc.network_name
  subnets       = var.subnets
  flow_sampling = 0.1
}

module "firewall" {
  source      = "../../modules/networking/firewall"
  project_id  = var.project_id
  vpc_name    = module.vpc.network_name
  vpc_cidr    = var.vpc_cidr
  name_prefix = "tms-dev"
  depends_on  = [module.vpc]
}

resource "google_compute_global_address" "private_ip_alloc" {
  name          = "${var.vpc_name}-private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.vpc.network_id
  project       = var.project_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = module.vpc.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

module "db" {
  source                = "../../modules/database/cloud-sql"
  project_id            = var.project_id
  region                = var.region
  instance_name         = "tms-dev-db"
  vpc_id                = module.vpc.network_id
  db_peering_connection = google_service_networking_connection.private_vpc_connection.id
  db_username           = "postgres"
  db_name               = "dev-services-db"
  secret_name           = "tms-dev-db-password"
}
