# ═══════════════════════════════════════════════════════════════
# MODULE: database/cloud-sql
# AWS EQUIVALENT: AWS RDS PostgreSQL
#
# Matches AWS dev-services-db:
# → db.t4g.large  = db-custom-2-8192 (2vCPU, 8GB)
# → PostgreSQL 16 = POSTGRES_16
# → 200 GiB gp3  = 200 GB PD_SSD
# → No Multi-AZ  = ZONAL
# → Storage autoscaling ON
# → Deletion protection ON
#
# ALSO CREATES:
# → Default database
# → Postgres user with random password
# → Password stored in Secret Manager
# ═══════════════════════════════════════════════════════════════

# Cloud SQL Instance
resource "google_sql_database_instance" "instance" {
  name                = var.instance_name
  project             = var.project_id
  region              = var.region
  database_version    = var.database_version
  deletion_protection = true

  # Wait for PSA VPC peering to be established
  depends_on = [var.db_peering_connection]

  settings {
    tier    = "db-custom-2-8192" # 2 vCPU 8GB = db.t4g.large
    edition = "ENTERPRISE"

    ip_configuration {
      ipv4_enabled                                  = false      # No public IP
      private_network                               = var.vpc_id # Private IP via PSA
      enable_private_path_for_google_cloud_services = true
    }

    availability_type     = "ZONAL"  # No Multi-AZ for dev
    disk_type             = "PD_SSD" # matches gp3
    disk_size             = 200      # matches 200 GiB
    disk_autoresize       = true     # matches storage autoscaling
    disk_autoresize_limit = 1000     # matches 1000 GiB threshold

    backup_configuration {
      enabled                        = true
      start_time                     = "02:00"
      point_in_time_recovery_enabled = true
    }

    maintenance_window {
      day          = 7
      hour         = 3
      update_track = "stable"
    }

    insights_config {
      query_insights_enabled = true
    }
  }
}

# Default database
resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.instance.name
  project  = var.project_id
}

# Generate secure random password
resource "random_password" "db_password" {
  length  = 16
  special = false
}

# Create postgres user
resource "google_sql_user" "db_user" {
  name     = var.db_username
  instance = google_sql_database_instance.instance.name
  password = random_password.db_password.result
  project  = var.project_id
}

# Store password in Secret Manager
resource "google_secret_manager_secret" "db_pass_secret" {
  secret_id = var.secret_name
  project   = var.project_id
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_pass_version" {
  secret      = google_secret_manager_secret.db_pass_secret.id
  secret_data = random_password.db_password.result
}
