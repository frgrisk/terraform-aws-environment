module "on_demand_requests" {
  source  = "frgrisk/ec2-instance/aws"
  version = "~>0.4.0"

  for_each = var.on_demand_requests

  ami                  = each.value.ami
  hostname             = coalesce(each.value.hostname, "${each.key}-${var.tag_environment}.${var.route53_zone_name}")
  iam_instance_profile = each.value.iam_instance_profile
  key_name             = var.key_name
  placement_group      = each.value.placement_group
  security_group_ids = concat(
    each.value.security_group_ids,
    [module.inter_environment_traffic.security_group_id],
  )
  subnet_id          = each.value.subnet_type == "public" ? aws_subnet.public[coalesce(each.value.availability_zone, local.default_az)].id : aws_subnet.private[coalesce(each.value.availability_zone, local.default_az)].id
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

resource "aws_eip" "on_demand_requests" {
  for_each = { for name, instance in var.on_demand_requests : name => coalesce(instance.hostname, "${name}-${var.tag_environment}.${var.route53_zone_name}") if instance.subnet_type == "public" }

  tags = {
    Environment : var.tag_environment,
    Hostname : each.value,
    Name : each.value,
  }
}

resource "aws_eip_association" "on_demand_requests" {
  for_each = { for name, instance in var.on_demand_requests : name => module.on_demand_requests[name] if instance.subnet_type == "public" }

  instance_id   = each.value.instance_id
  allocation_id = aws_eip.on_demand_requests[each.key].id
}

resource "aws_route53_record" "on_demand_requests" {
  for_each = var.on_demand_requests
  zone_id  = var.route53_zone_id
  name     = module.on_demand_requests[each.key].hostname
  type     = "A"
  records  = [each.value.subnet_type == "public" ? aws_eip.on_demand_requests[each.key].public_ip : module.on_demand_requests[each.key].private_ip]
  ttl      = "60"
}
