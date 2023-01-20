locals {
  default_az = coalesce(var.default_availability_zone, data.aws_availability_zones.region.names[0])
}

resource "aws_placement_group" "pg" {
  name     = var.placement_group_name == "" ? "pg-${var.tag_environment}" : var.placement_group_name
  strategy = "cluster"
}

module "spot_requests" {
  source  = "frgrisk/ec2-spot/aws"
  version = "0.1.0"

  for_each = var.spot_requests

  ami                  = each.value["ami"]
  hostname             = "${each.key}-${var.tag_environment}.${var.route53_zone_name}"
  iam_instance_profile = lookup(each.value, "iam_instance_profile", null)
  key_name             = var.key_name
  placement_group_name = aws_placement_group.pg.name
  security_group_ids = concat(
    split(",", lookup(each.value, "security_group_ids", null)),
    [module.inter_environment_traffic.security_group_id],
  )
  subnet_id          = aws_subnet.private[lookup(each.value, "availability_zone", local.default_az)].id
  tag_environment    = var.tag_environment
  type               = lookup(each.value, "type", null)
  user_data          = lookup(each.value, "user_data", null)
  raid_array_size    = lookup(each.value, "raid_array_size", 0)
  root_volume_size   = lookup(each.value, "root_volume_size", 30)
  additional_volumes = lookup(var.additional_volumes, each.key, {})

  user_data_replace_on_change = lookup(each.value, "user_data_replace_on_change", true)
}

resource "aws_route53_record" "instances" {
  for_each = var.spot_requests
  zone_id  = var.route53_zone_id
  name     = module.spot_requests[each.key].hostname
  type     = "A"
  records  = [module.spot_requests[each.key].private_ip]
  ttl      = "60"
}