variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance"
  type        = string
}

variable "config_source" {
  description = "Source of the CloudWatch Agent configuration file ('local' or 's3')"
  type        = string
  default     = "s3"
}

variable "local_config_file_path" {
  description = "Local file path for CloudWatch Agent configuration (if using local source)"
  type        = string
  default     = ""
}

variable "s3_bucket_name" {
  description = "S3 bucket name for CloudWatch Agent config (if using S3 source)"
  type        = string
  default     = ""
}

variable "s3_config_url" {
  description = "URL of the S3 object containing the CloudWatch Agent config"
  type        = string
  default     = ""
}

variable "agent_installed_check_command" {
  description = "Command to check if the CloudWatch Agent is already installed"
  type        = string
  default     = "which amazon-cloudwatch-agent"
}

variable "install_agent_command" {
  description = "Command to install the CloudWatch Agent if not installed"
  type        = string
  default     = "yum install -y amazon-cloudwatch-agent"
}
