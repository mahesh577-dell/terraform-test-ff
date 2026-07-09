output "vpc_name" {
  value = module.vpc.vpc_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnets" {
  value = module.subnets.subnet_cidrs
}

output "cloud_router" {
  value = module.cloud_router.router_name
}

output "cloud_nat" {
  value = module.nat.nat_name
}

output "firewall_rules" {
  value = module.firewall.firewall_rules
}

output "artifact_registry_url" {
  description = "Push/pull images here for tms-dev"
  value       = module.artifact_registry.registry_url
}
