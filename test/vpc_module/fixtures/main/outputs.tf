# outputs.tf
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "nat_gateway_id" {
  value = module.vpc.nat_gateway_id
}

output "internet_gateway_id" {
  value = module.vpc.internet_gateway_id
}

output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}

output "public_route_table_ids" {
  value = module.vpc.public_route_table_ids
}

output "rds_subnets" {
  value = module.vpc.rds_subnets
}

output "custom_subnet_ids" {
  value = module.vpc.custom_subnet_ids
}

output "custom_subnet_cidrs" {
  value = module.vpc.custom_subnet_cidrs
}

output "custom_subnet_azs" {
  value = module.vpc.custom_subnet_azs
}

output "custom_subnets_by_name" {
  value = module.vpc.custom_subnets_by_name
}

output "vpc_endpoints" {
  value = module.vpc.vpc_endpoints
}
