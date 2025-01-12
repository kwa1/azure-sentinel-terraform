# Data source to find existing EC2 instances by tag
data "aws_instances" "existing_instances" {
  filter {
    name   = "tag:Name"
    values = [var.instance_name_tag]
  }
}

# Local variable to determine if any EC2 instance is found
locals {
  is_instance_provisioned = length(data.aws_instances.existing_instances.ids) > 0
}

# User-data script for installing CloudWatch Agent only if it's not already installed
data "template_file" "cloudwatch_agent_userdata" {
  template = <<-EOF
    #!/bin/bash
    # Check if CloudWatch Agent is already installed
    if [ -x "$(command -v amazon-cloudwatch-agent)" ]; then
      echo "CloudWatch Agent is already installed. Skipping installation." >> /var/log/cloudwatch_agent_setup.log
      exit 0
    fi

    # Determine configuration source
    CONFIG_SOURCE={{ config_source }}
    CONFIG_PATH={{ config_path }}

    # Install CloudWatch Agent
    yum install -y amazon-cloudwatch-agent >> /var/log/cloudwatch_agent_setup.log 2>&1

    # Ensure the configuration directory exists
    mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/

    if [ "$CONFIG_SOURCE" == "s3" ]; then
      # Download the configuration file from S3
      aws s3 cp $CONFIG_PATH /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json >> /var/log/cloudwatch_agent_setup.log 2>&1
    elif [ "$CONFIG_SOURCE" == "local" ]; then
      # Use the local configuration file path
      cp $CONFIG_PATH /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json >> /var/log/cloudwatch_agent_setup.log 2>&1
    fi

    # Validate the CloudWatch Agent configuration file
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard --validate >> /var/log/cloudwatch_agent_setup.log 2>&1

    # Start the CloudWatch Agent
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a start -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json >> /var/log/cloudwatch_agent_setup.log 2>&1

    # Enable the CloudWatch Agent service to start on boot
    systemctl enable amazon-cloudwatch-agent >> /var/log/cloudwatch_agent_setup.log 2>&1
  EOF

  vars = {
    config_source = var.config_source
    config_path   = var.config_source == "local" ? var.local_config_file_path : "s3://${var.s3_bucket_name}/${var.s3_config_key}"
  }
}

# If an instance exists, use AWS Systems Manager (SSM) to install CloudWatch Agent on it
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
            "yum install -y amazon-cloudwatch-agent",
            "mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/",
            "CONFIG_SOURCE=${var.config_source}",
            "CONFIG_PATH=${var.config_source == "local" ? var.local_config_file_path : "s3://${var.s3_bucket_name}/${var.s3_config_key}"}",
            "if [ "$CONFIG_SOURCE" == "s3" ]; then",
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

# Provision EC2 instance only if no existing EC2 instance is found
resource "aws_instance" "cloudwatch_agent_instance" {
  count         = local.is_instance_provisioned ? 0 : 1
  ami           = var.ami_id
  instance_type = var.instance_type
  user_data     = data.template_file.cloudwatch_agent_userdata.rendered

  tags = {
    Name = var.instance_name_tag
  }
}
