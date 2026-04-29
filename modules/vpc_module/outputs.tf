# outputs.tf
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "public_subnet_ids" {
  description = "Alias of public_subnets for clarity"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "private_subnet_ids" {
  description = "Alias of private_subnets for clarity"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway in single-gateway mode. Null when nat_gateway_per_az is true or no gateway is created."
  value       = (!var.nat_gateway_per_az && var.create_nat_gateway) ? aws_nat_gateway.this[local.all_azs[0]].id : null
}

output "nat_gateway_ids" {
  description = "Map of AZ to NAT Gateway ID for all created NAT Gateways."
  value       = { for az, ngw in aws_nat_gateway.this : az => ngw.id }
}

output "internet_gateway_id" {
  description = "ID of the internet gateway if created"
  value       = length(aws_internet_gateway.this) > 0 ? aws_internet_gateway.this[0].id : null
}

output "private_route_table_ids" {
  description = "List of route table IDs associated with private subnets"
  value       = [for rt in aws_route_table.private : rt.id]
}

output "public_route_table_ids" {
  description = "List of route table IDs associated with public subnets"
  value       = [for rt in aws_route_table.public : rt.id]
}

output "rds_subnets" {
  description = "List of RDS subnet IDs (if created)"
  value       = var.create_rds_subnets ? [for s in aws_subnet.rds : s.id] : []
}

output "rds_subnet_ids" {
  description = "List of RDS Subnet IDs"
  value       = [for s in aws_subnet.rds : s.id]
}

output "custom_subnet_ids" {
  description = "Map of custom subnet names to IDs"
  value = {
    for s in aws_subnet.custom_subnet :
    s.tags["Name"] => s.id
  }
}

output "custom_subnet_cidrs" {
  description = "List of custom subnet CIDR blocks"
  value       = [for subnet in aws_subnet.custom_subnet : subnet.cidr_block]
}

output "custom_subnet_azs" {
  description = "List of availability zones for custom subnets"
  value       = [for subnet in aws_subnet.custom_subnet : subnet.availability_zone]
}

output "custom_subnets_by_name" {
  description = "Map of custom subnets by name, with ID, CIDR, and AZ"
  value = {
    for k, v in aws_subnet.custom_subnet : v.tags["Name"] => {
      id   = v.id
      cidr = v.cidr_block
      az   = v.availability_zone
    }
  }
}

output "vpc_endpoints" {
  description = "Map of VPC endpoints created"
  value = {
    for k, ep in aws_vpc_endpoint.this :
    k => ep.service_name
  }
}

output "vpc_flow_log_group_name" {
  description = "Name of the VPC flow log CloudWatch Log Group"
  value       = try(aws_cloudwatch_log_group.vpc_flow_logs[0].name, null)
}
