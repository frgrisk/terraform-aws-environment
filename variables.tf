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
    additional_tags             = optional(map(string))
    subnet_type                 = optional(string)
  }))
  default = {}
}

variable "on_demand_requests" {
  description = "Map of on-demand requests to on-demand instance variables"
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
    additional_tags             = optional(map(string))
    subnet_type                 = optional(string)
  }))
  default = {}
}

variable "backup" {
  description = "Map of backup variables"
  type = object({
    enabled   = bool
    schedule  = optional(string)
    retention = optional(number)
  })
  default = {
    enabled = false
  }

  validation {
    condition     = var.backup.enabled == true ? var.backup.schedule != null && var.backup.retention != null : true
    error_message = "If backup is enabled, schedule and retention must be set"
  }

  validation {
    condition     = var.backup.enabled == false ? var.backup.schedule == null && var.backup.retention == null : true
    error_message = "If backup is disabled, schedule and retention must be null"
  }
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
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

variable "allow_intra_environment_traffic" {
  description = "Automatically attach a security group to instances to allow intra-environment traffic"
  type        = bool
  default     = true
}
