# terraform-aws-environment

Terraform module to create a server environment in AWS. It provisions networking resources, optional backups and EC2 instances (on‑demand and spot) with DNS records.

## Features

- Creates private and public subnets in every availability zone of the current region
- Associates subnets with provided route tables
- Optional security group allowing traffic between all instances in the environment
- Deploys on‑demand and spot instances using the `frgrisk/ec2-instance` and `frgrisk/ec2-spot` modules
- Creates forward and reverse Route53 records for all instances
- Supports optional AWS Backup plans
- Additional encrypted volumes can be attached to instances

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Usage

```hcl
module "environment" {
  source = "github.com/FRG/terraform-aws-environment"

  tag_environment        = "prod"
  vpc_id                 = aws_vpc.main.id
  environment_cidr       = "10.0.0.0/16"
  route53_zone_name      = "example.com"
  route53_zone_id        = data.aws_route53_zone.primary.zone_id
  key_name               = "my-keypair"
  public_route_table_id  = aws_route_table.public.id
  private_route_table_id = aws_route_table.private.id

  on_demand_requests = {
    server1 = {
      ami                = "ami-abc123"
      type               = "t3.micro"
      security_group_ids = [aws_security_group.common.id]
    }
  }
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `spot_requests` | Map of spot requests to spot instance variables | `map(object(...))` | `{}` |
| `on_demand_requests` | Map of on-demand requests to on-demand instance variables | `map(object(...))` | `{}` |
| `backup` | Map of backup variables | `object({enabled=bool, schedule=string, retention=number})` | `{ enabled = false }` |
| `default_tags` | Default tags to apply to all resources | `map(string)` | `{}` |
| `tag_environment` | The name of the environment to use in resource tagging | `string` | n/a |
| `vpc_id` | The VPC to deploy into | `string` | n/a |
| `default_availability_zone` | The default availability zone to deploy into | `string` | `""` |
| `environment_cidr` | The CIDR block of the environment. This block will be divided into public and private subnets for all AZs in the region | `string` | n/a |
| `route53_zone_name` | The parent domain name to use for the instances created | `string` | n/a |
| `route53_zone_id` | The Route53 zone ID to use for the instances created | `string` | n/a |
| `key_name` | The name of the key pair to use for the instances created | `string` | n/a |
| `additional_volumes` | Additional volumes to create and attach to the instances | `map(map(map(string)))` | `{}` |
| `public_route_table_id` | Public route table ID to associate with new public subnets | `string` | n/a |
| `private_route_table_id` | Private route table ID to associate with new private subnets | `string` | n/a |
| `encrypt_volumes` | Flag to enable encryption of volumes | `bool` | `true` |
| `allow_intra_environment_traffic` | Automatically attach a security group to instances to allow intra-environment traffic | `bool` | `true` |

### Instance request object

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `availability_zone` | `string` | no | Availability zone to deploy the instance |
| `type` | `string` | yes | EC2 instance type |
| `hostname` | `string` | no | Hostname to register in Route53 |
| `ami` | `string` | yes | AMI ID for the instance |
| `iam_instance_profile` | `string` | no | IAM instance profile name |
| `raid_array_size` | `number` | no | Size of ephemeral RAID array |
| `root_volume_size` | `number` | no | Root volume size in GB |
| `security_group_ids` | `list(string)` | yes | Security group IDs to attach |
| `user_data` | `string` | no | User data script |
| `user_data_replace_on_change` | `bool` | no | Recreate instance when user data changes |
| `placement_group` | `string` | no | Placement group for the instance |
| `additional_tags` | `map(string)` | no | Extra tags to apply |
| `subnet_type` | `string` | no | `public` or `private` subnet placement |

### Backup object

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `enabled` | `bool` | yes | Whether to enable backups |
| `schedule` | `string` | when `enabled` | Cron schedule for the backup plan |
| `retention` | `number` | when `enabled` | Number of days to keep backups |

## Outputs

| Name | Description |
|------|-------------|
| `private_subnets_cidr_blocks` | List of cidr_blocks of private subnets |
| `public_subnets_cidr_blocks` | List of cidr_blocks of public subnets |
| `private_subnets` | List of IDs of private subnets |
| `private_subnets_by_az` | Map of private subnets by availability zone |
| `public_subnets` | List of IDs of public subnets |
| `public_subnets_by_az` | Map of public subnets by availability zone |
| `intra_environment_security_group_id` | ID of the intra-environment security group |
| `inter_environment_security_group_id` | DEPRECATED: ID of the intra-environment security group |
| `private_ip_addresses_on_demand` | List of private IP addresses allocated to on-demand instances |
| `private_ip_addresses_spot` | List of private IP addresses allocated to spot instances |
| `instance_ids_on_demand` | List of instance IDs for on-demand instances |
| `instance_ids_spot` | List of instance IDs for spot instances |
| `reverse_dns_zone_name` | Reverse DNS zone name |
| `reverse_dns_zone_id` | Reverse DNS zone ID |

## License

[MIT](LICENSE)
