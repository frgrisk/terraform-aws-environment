resource "aws_backup_plan" "environment" {
  name = "${var.tag_environment}-backup-plan"

  rule {
    rule_name         = "10-day-retention"
    target_vault_name = aws_backup_vault.environment.name
    schedule          = "cron(0 7 * * ? *)"

    lifecycle {
      delete_after = 10
    }
  }

  tags = {
    Environment = var.tag_environment
  }
}

resource "aws_backup_vault" "environment" {
  name = "${var.tag_environment}-backup-vault"
  tags = {
    Environment = var.tag_environment
  }
}

resource "aws_backup_selection" "environment" {
  iam_role_arn = aws_iam_role.backup.arn
  name         = "${var.tag_environment}-servers"
  plan_id      = aws_backup_plan.environment.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Environment"
    value = var.tag_environment
  }
}

resource "aws_iam_role" "backup" {
  name_prefix        = "backup-role-${var.tag_environment}-"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "backup" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup.name
}
