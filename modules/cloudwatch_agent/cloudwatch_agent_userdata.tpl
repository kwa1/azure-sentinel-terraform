# This template will render the EC2 User Data script dynamically.
#!/bin/bash

# Check if CloudWatch Agent is already installed
if ${agent_installed_check}; then
  echo "CloudWatch Agent is already installed. Skipping installation."
else
  echo "CloudWatch Agent not found. Installing..."
  ${install_agent_command}
fi

# Download or copy the configuration file based on the source
if [ "${config_source_condition}" == "s3" ]; then
  echo "Downloading CloudWatch Agent config from S3..."
  aws s3 cp ${config_file_path} /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
else
  echo "Using local CloudWatch Agent config file..."
  cp ${config_file_path} /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
fi

# Start the CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Enable the CloudWatch Agent to start on boot
systemctl enable amazon-cloudwatch-agent
