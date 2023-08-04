output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = local.private_subnet_cidrs
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = local.public_subnet_cidrs
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = [for k, v in aws_subnet.private : v.id]
}

output "private_subnets_by_az" {
  description = "Map of private subnets by availability zone"
  value       = aws_subnet.private
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = [for k, v in aws_subnet.public : v.id]
}

output "public_subnets_by_az" {
  description = "Map of public subnets by availability zone"
  value       = aws_subnet.public
}

output "inter_environment_security_group_id" {
  description = "ID of the inter-environment security group"
  value       = module.inter_environment_traffic.security_group_id
}

output "private_ip_addresses_on_demand" {
    description = "List of private IP addresses allocated to on-demand instances"
    value       = {for name, instance in module.on_demand_requests : name => instance.private_ip}
}

output "private_ip_addresses_spot" {
    description = "List of private IP addresses allocated to spot instances"
    value       = {for name, instance in module.spot_requests : name => instance.private_ip}
}

output "instance_ids_on_demand" {
    description = "List of instance IDs for on-demand instances"
    value       = {for name, instance in module.on_demand_requests : name => instance.instance_id}
}

output "instance_ids_spot" {
    description = "List of instance IDs for spot instances"
    value       = {for name, instance in module.spot_requests : name => instance.instance_id}
}
