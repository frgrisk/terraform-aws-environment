resource "aws_backup_plan" "environment" {
  name  = "${var.tag_environment}-backup-plan"
  count = var.backup.enabled ? 1 : 0

  rule {
    rule_name         = "${var.backup.retention}-day-retention"
    target_vault_name = aws_backup_vault.environment[0].name
    schedule          = var.backup.schedule

    lifecycle {
      delete_after = var.backup.retention
    }
  }

  tags = {
    Environment = var.tag_environment
  }
}

resource "aws_backup_vault" "environment" {
  count = var.backup.enabled ? 1 : 0
  name  = "${var.tag_environment}-backup-vault"
  tags = {
    Environment = var.tag_environment
  }
}

resource "aws_backup_selection" "environment" {
  count        = var.backup.enabled ? 1 : 0
  iam_role_arn = aws_iam_role.backup[0].arn
  name         = "${var.tag_environment}-servers"
  plan_id      = aws_backup_plan.environment[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Environment"
    value = var.tag_environment
  }
}

resource "aws_iam_role" "backup" {
  count              = var.backup.enabled ? 1 : 0
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
  count      = var.backup.enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup[0].name
}
