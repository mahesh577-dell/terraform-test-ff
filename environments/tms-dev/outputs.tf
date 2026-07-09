output "vpc_name" {
  value = module.vpc.network_name
}

output "subnets" {
  value = module.subnets.subnet_cidrs
}

output "firewall_rules" {
  value = module.firewall.firewall_rules
}

output "cloud_sql_instance" {
  value = module.db.instance_name
}

output "cloud_sql_private_ip" {
  value = module.db.private_ip
}

output "db_password_secret" {
  value = module.db.db_password_secret
}
