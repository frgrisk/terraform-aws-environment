locals {
  number_of_subnets = length(data.aws_availability_zones.region.names) * 2
  all_subnets = cidrsubnets(
    var.environment_cidr,
    [
      for i in range(0, local.number_of_subnets) : ceil(log(local.number_of_subnets, 2))
    ]...
  )
  private_subnet_cidrs = slice(local.all_subnets, 0, local.number_of_subnets / 2)
  public_subnet_cidrs  = slice(local.all_subnets, local.number_of_subnets / 2, local.number_of_subnets)
}

data "aws_availability_zones" "region" {
  region = var.region

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

resource "aws_subnet" "private" {
  region   = var.region
  for_each = toset(data.aws_availability_zones.region.names)
  tags = {
    Name        = "${var.tag_environment}-private-${each.key}"
    Environment = var.tag_environment
  }
  vpc_id            = var.vpc_id
  cidr_block        = local.private_subnet_cidrs[index(data.aws_availability_zones.region.names, each.key)]
  availability_zone = each.key
}

resource "aws_subnet" "public" {
  region   = var.region
  for_each = toset(data.aws_availability_zones.region.names)
  tags = {
    Name        = "${var.tag_environment}-public-${each.key}"
    Environment = var.tag_environment
  }
  vpc_id            = var.vpc_id
  cidr_block        = local.public_subnet_cidrs[index(data.aws_availability_zones.region.names, each.key)]
  availability_zone = each.key
}

resource "aws_route_table_association" "private" {
  region   = var.region
  for_each = aws_subnet.private

  route_table_id = var.private_route_table_id
  subnet_id      = each.value.id
}

resource "aws_route_table_association" "public" {
  region   = var.region
  for_each = aws_subnet.public

  route_table_id = var.public_route_table_id
  subnet_id      = each.value.id
}

module "intra_environment_traffic" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~>6.0"
  region  = var.region

  name        = "${var.tag_environment} inter-subnet traffic"
  description = "${var.tag_environment} inter-subnet traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.tag_environment} inter-subnet traffic"
  }

  ingress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = var.environment_cidr
      description = "Allow all traffic between subnets in the environment"
    }
  }

  egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all outbound traffic"
    }
  }
}

moved {
  from = module.inter_environment_traffic
  to   = module.intra_environment_traffic
}
