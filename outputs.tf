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

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = [for k, v in aws_subnet.public : v.id]
}
