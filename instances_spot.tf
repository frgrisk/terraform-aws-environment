locals {
  default_az = coalesce(var.default_availability_zone, data.aws_availability_zones.region.names[0])
}

module "spot_requests" {
  source  = "frgrisk/ec2-spot/aws"
  version = "~>0.3.2"

  for_each = var.spot_requests

  ami                  = each.value.ami
  hostname             = coalesce(each.value.hostname, "${each.key}-${var.tag_environment}.${var.route53_zone_name}")
  iam_instance_profile = each.value.iam_instance_profile
  key_name             = var.key_name
  placement_group      = each.value.placement_group
  security_group_ids = concat(
    each.value.security_group_ids,
    [module.inter_environment_traffic.security_group_id],
  )
  subnet_id          = aws_subnet.private[coalesce(each.value.availability_zone, local.default_az)].id
  tag_environment    = var.tag_environment
  type               = each.value.type
  user_data          = each.value.user_data
  raid_array_size    = coalesce(each.value.raid_array_size, 0)
  root_volume_size   = coalesce(each.value.root_volume_size, 30)
  additional_volumes = lookup(var.additional_volumes, each.key, {})
  encrypt_volumes    = var.encrypt_volumes
  additional_tags    = merge(var.default_tags, each.value.additional_tags)

  user_data_replace_on_change = coalesce(each.value.user_data_replace_on_change, true)
}

resource "aws_route53_record" "spot_requests" {
  for_each = var.spot_requests
  zone_id  = var.route53_zone_id
  name     = module.spot_requests[each.key].hostname
  type     = "A"
  records  = [module.spot_requests[each.key].private_ip]
  ttl      = "60"
}
