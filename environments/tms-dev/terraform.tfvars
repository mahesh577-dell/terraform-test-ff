project_id = "ccd-poc-project"
region     = "asia-south1"
vpc_name   = "tms-dev-vpc"
vpc_cidr   = "10.60.0.0/16"

subnets = {
  "tms-dev-public-1a" = {
    cidr                     = "10.60.1.0/24"
    region                   = "asia-south1"
    description              = "Public Zone A - Load Balancer Bastion"
    private_ip_google_access = false
  }
  "tms-dev-public-1b" = {
    cidr                     = "10.60.2.0/24"
    region                   = "asia-south1"
    description              = "Public Zone B - Load Balancer"
    private_ip_google_access = false
  }
  "tms-dev-private-1a" = {
    cidr                     = "10.60.3.0/24"
    region                   = "asia-south1"
    description              = "Private Zone A - GKE Nodes GCE Cloud Run"
    private_ip_google_access = true
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
  }
  "tms-dev-private-1b" = {
    cidr                     = "10.60.4.0/24"
    region                   = "asia-south1"
    description              = "Private Zone B - App servers"
    private_ip_google_access = true
  }
  "tms-dev-data-1a" = {
    cidr                     = "10.60.5.0/24"
    region                   = "asia-south1"
    description              = "Data Zone A - Cloud SQL"
    private_ip_google_access = false
  }
  "tms-dev-data-1b" = {
    cidr                     = "10.60.6.0/24"
    region                   = "asia-south1"
    description              = "Data Zone B - Cloud SQL"
    private_ip_google_access = false
  }
  "tms-dev-data-1c" = {
    cidr                     = "10.60.7.0/24"
    region                   = "asia-south1"
    description              = "Data Zone C - Cloud SQL"
    private_ip_google_access = false
  }
}
