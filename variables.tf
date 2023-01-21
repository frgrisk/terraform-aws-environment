variable "spot_requests" {
  description = "Map of spot requests to spot instance variables"
  type        = map(map(any))
}

variable "tag_environment" {
  description = "The name of the environment to use in resource tagging"
  type        = string
}

variable "placement_group_name" {
  description = "The name of the placement group to create"
  default     = ""
  type        = string
}

variable "vpc_id" {
  description = "The VPC to deploy into"
  type        = string
}

variable "default_availability_zone" {
  description = "The default availability zone to deploy into"
  type        = string
  default     = ""
}

variable "environment_cidr" {
  description = "The CIDR block of the environment. This block will be divided into public and private subnets for all AZs in the region"
  type        = string
}

variable "route53_zone_name" {
  description = "The parent domain name to use for the instances created"
  type        = string
}

variable "route53_zone_id" {
  description = "The Route53 zone ID to use for the instances created"
  type        = string
}

variable "key_name" {
  description = "The name of the key pair to use for the instances created"
  type        = string
}

variable "additional_volumes" {
  description = "Additional volumes to create and attach to the instances"
  type        = map(map(map(string)))
  default     = {}
}

variable "public_route_table_id" {
  description = "Public route table ID to associate with new public subnets"
  type        = string
}

variable "private_route_table_id" {
  description = "Private route table ID to associate with new private subnets"
  type        = string
}
