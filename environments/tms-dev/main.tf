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
  source      = "../../modules/vpc"
  project_id  = var.project_id
  vpc_name    = var.vpc_name
  description = "TMS DEV VPC FreightFox 10.60.0.0/16"
}

module "subnets" {
  source        = "../../modules/subnet"
  project_id    = var.project_id
  region        = var.region
  vpc_self_link = module.vpc.vpc_self_link
  flow_sampling = 0.1

  subnets = [
    {
      name        = "tms-dev-public-1a"
      cidr        = "10.60.1.0/24"
      description = "Public Zone A Load Balancer Bastion"
    },
    {
      name        = "tms-dev-public-1b"
      cidr        = "10.60.2.0/24"
      description = "Public Zone B Load Balancer"
    },
    {
      name        = "tms-dev-private-1a"
      cidr        = "10.60.3.0/24"
      description = "Private Zone A GKE Nodes GCE Cloud Run"
      secondary_ranges = [
        {
          range_name    = "tms-dev-pods"
          ip_cidr_range = "10.60.16.0/20"
        },
        {
          range_name    = "tms-dev-services"
          ip_cidr_range = "10.60.32.0/20"
        }
      ]
    },
    {
      name        = "tms-dev-private-1b"
      cidr        = "10.60.4.0/24"
      description = "Private Zone B App servers"
    },
    {
      name        = "tms-dev-data-1a"
      cidr        = "10.60.5.0/24"
      description = "Data Zone A Cloud SQL"
    },
    {
      name        = "tms-dev-data-1b"
      cidr        = "10.60.6.0/24"
      description = "Data Zone B Cloud SQL"
    },
    {
      name        = "tms-dev-data-1c"
      cidr        = "10.60.7.0/24"
      description = "Data Zone C Cloud SQL"
    },
  ]

  depends_on = [module.vpc]
}

module "firewall" {
  source      = "../../modules/firewall"
  project_id  = var.project_id
  vpc_name    = module.vpc.vpc_name
  vpc_cidr    = var.vpc_cidr
  name_prefix = "tms-dev"
  depends_on  = [module.vpc]
}

module "cloud_router" {
  source        = "../../modules/cloud_router"
  project_id    = var.project_id
  region        = var.region
  router_name   = "tms-dev-router"
  vpc_self_link = module.vpc.vpc_self_link
  bgp_asn       = 64514
  depends_on    = [module.vpc]
}

module "nat" {
  source      = "../../modules/nat"
  project_id  = var.project_id
  region      = var.region
  nat_name    = "tms-dev-nat"
  router_name = module.cloud_router.router_name

  private_subnet_self_links = [
    module.subnets.subnet_self_links["tms-dev-private-1a"],
    module.subnets.subnet_self_links["tms-dev-private-1b"],
  ]

  depends_on = [module.cloud_router, module.subnets]
}

module "artifact_registry" {
  source      = "../../modules/artifact-registry"
  project_id  = var.project_id
  region      = var.region
  environment = var.environment
}
