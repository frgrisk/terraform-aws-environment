locals {
  number_of_subnets = length(data.aws_availability_zones.region.names) * 2
  all_subnets = cidrsubnets(
    var.environment_cidr,
    [
      for i in range(0, local.number_of_subnets) : ceil(log(local.number_of_subnets, 2))
    ]...
  )
  private_subnets = slice(local.all_subnets, 0, local.number_of_subnets / 2)
  public_subnets  = slice(local.all_subnets, local.number_of_subnets / 2, local.number_of_subnets)
}

data "aws_region" "current" {}

data "aws_availability_zones" "region" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }

  filter {
    name   = "region-name"
    values = [data.aws_region.current.name]
  }
}

resource "aws_subnet" "private" {
  for_each = toset(data.aws_availability_zones.region.names)
  tags = {
    Name        = "${var.tag_environment}-private-${each.key}"
    Environment = var.tag_environment
  }
  vpc_id            = var.vpc_id
  cidr_block        = local.private_subnets[index(data.aws_availability_zones.region.names, each.key)]
  availability_zone = each.key
}

resource "aws_subnet" "public" {
  for_each = toset(data.aws_availability_zones.region.names)
  tags = {
    Name        = "${var.tag_environment}-public-${each.key}"
    Environment = var.tag_environment
  }
  vpc_id            = var.vpc_id
  cidr_block        = local.public_subnets[index(data.aws_availability_zones.region.names, each.key)]
  availability_zone = each.key
}

module "inter_environment_traffic" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.tag_environment} inter-subnet traffic"
  description = "${var.tag_environment} inter-subnet traffic"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = [var.environment_cidr]

  ingress_rules = ["all-all"]
  egress_rules  = ["all-all"]
}
