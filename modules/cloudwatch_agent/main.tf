# EC2 instance resource
# Data source to find existing EC2 instances by tag

data "aws_instances" "existing_instances" {
  filter {
    name   = "tag:Name"
    values = [var.instance_name_tag]
  }
}

# Check if any instances already exist
locals {
  is_instance_provisioned = length(data.aws_instances.existing_instances.ids) > 0
}

# Conditional resource for provisioning an EC2 instance
resource "aws_instance" "cloudwatch_agent_instance" {
  count = local.is_instance_provisioned ? 0 : 1

  ami           = var.ami_id
  instance_type = var.instance_type

  # Dynamic user-data for installing CloudWatch agent
  user_data = templatefile("${path.module}/cloudwatch_agent_userdata.tpl", {
    agent_installed_check   = var.agent_installed_check_command
    install_agent_command   = var.install_agent_command
    config_source_condition = var.config_source == "local" ? "file" : "s3"
    config_file_path        = var.config_source == "local" ? var.local_config_file_path : var.s3_config_url
  })

  tags = {
    Name = var.instance_name_tag
  }
}

# S3 bucket object for config (if config_source is S3)
resource "aws_s3_bucket_object" "cloudwatch_agent_config" {
  count  = var.config_source == "s3" ? 1 : 0
  bucket = var.s3_bucket_name
  key    = "amazon-cloudwatch-agent.json"
  source = var.local_config_file_path

  # Enforce encryption and secure transfer
  server_side_encryption = "AES256"
  bucket_key_enabled     = true
}

# Install CloudWatch agent on existing instances (using SSM)
resource "aws_ssm_document" "install_cloudwatch_agent" {
  count = local.is_instance_provisioned ? 1 : 0

  name          = "InstallCloudWatchAgent"
  document_type = "Command"

  content = <<-EOT
  {
    "schemaVersion": "2.2",
    "description": "Install CloudWatch Agent",
    "mainSteps": [
      {
        "action": "aws:runShellScript",
        "name": "InstallCloudWatchAgent",
        "inputs": {
          "runCommand": [
            "#!/bin/bash",
            "if [ -x \\"$(command -v amazon-cloudwatch-agent)\\" ]; then",
            "  echo \\"CloudWatch Agent already installed. Skipping installation.\\"",
            "  exit 0",
            "fi",
            "${var.install_agent_command}",
            "mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/",
            "CONFIG_SOURCE=${var.config_source}",
            "CONFIG_PATH=${var.config_source == "local" ? var.local_config_file_path : var.s3_config_url}",
            "if [ \\"$CONFIG_SOURCE\\" == \\"s3\\" ]; then",
            "  aws s3 cp $CONFIG_PATH /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json",
            "else",
            "  cp $CONFIG_PATH /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json",
            "fi",
            "/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json",
            "systemctl enable amazon-cloudwatch-agent"
          ]
        }
      }
    ]
  }
  EOT
}

resource "aws_ssm_association" "cloudwatch_agent_installation" {
  count            = local.is_instance_provisioned ? 1 : 0
  name             = aws_ssm_document.install_cloudwatch_agent.name
  targets          = [{ Key = "tag:Name", Values = [var.instance_name_tag] }]
  max_concurrency  = "1"
  max_errors       = "0"
}
