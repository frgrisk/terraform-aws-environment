variable "spot_requests" {
  description = "Map of spot requests to spot instance variables"
  type = map(object({
    availability_zone           = optional(string)
    type                        = string
    hostname                    = optional(string)
    ami                         = string
    iam_instance_profile        = optional(string)
    raid_array_size             = optional(number)
    root_volume_size            = optional(number)
    security_group_ids          = list(string)
    user_data                   = optional(string)
    user_data_replace_on_change = optional(bool)
    placement_group             = optional(string)
  }))
}

variable "tag_environment" {
  description = "The name of the environment to use in resource tagging"
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

variable "encrypt_volumes" {
  description = "Flag to enable encryption of volumes"
  type        = bool
  default     = true
}
