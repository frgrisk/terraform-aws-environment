# Reverse DNS zone for subnet
locals {
  # 1) Split CIDR into [address, mask]
  cidr_parts = split("/", var.environment_cidr)

  # 2) Convert mask to number
  mask_bits = tonumber(local.cidr_parts[1])

  # 3) Compute the network address (host bits = 0)
  #    "cidrhost(..., 0)" returns the base network address of that CIDR.
  network_address = cidrhost(var.environment_cidr, 0)

  # 4) Split the network address (e.g. "10.0.1.0") into ["10", "0", "1", "0"]
  address_octets = split(".", local.network_address)

  # 5) Figure out how many octets are part of the “network” portion
  #    (Assuming mask_bits is multiple of 8, e.g. /8, /16, /24)
  #
  #    /8  => first 1 octet
  #    /16 => first 2 octets
  #    /24 => first 3 octets
  #    ...
  relevant_octets = slice(local.address_octets, 0, ceil(local.mask_bits / 8))

  # 6) Reverse the order (e.g. ["10", "0", "1"] => ["1", "0", "10"])
  reversed_octets = reverse(local.relevant_octets)

  # 7) Join reversed octets with '.' and add .in-addr.arpa
  reversed_zone_string = join(".", local.reversed_octets)
  reverse_dns_zone     = format("%s.in-addr.arpa", local.reversed_zone_string)
}

resource "aws_route53_zone" "reverse" {
  name = local.reverse_dns_zone

  vpc {
    vpc_id = var.vpc_id
  }

  tags = merge(var.default_tags, { Environment = var.tag_environment })
}

# PTR records for on-demand instances
resource "aws_route53_record" "ondemand_ptr" {
  for_each = var.on_demand_requests
  zone_id  = aws_route53_zone.reverse.zone_id
  name     = "${join(".", reverse(split(".", module.on_demand_requests[each.key].private_ip)))}.in-addr.arpa"
  type     = "PTR"
  ttl      = "300"
  records  = ["${module.on_demand_requests[each.key].hostname}."]
}

# PTR records for spot instances
resource "aws_route53_record" "spot_ptr" {
  for_each = var.spot_requests
  zone_id  = aws_route53_zone.reverse.zone_id
  name     = "${join(".", reverse(split(".", module.spot_requests[each.key].private_ip)))}.in-addr.arpa"
  type     = "PTR"
  ttl      = "300"
  records  = ["${module.spot_requests[each.key].hostname}."]
}
