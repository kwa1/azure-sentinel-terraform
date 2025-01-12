variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
}

variable "instance_name_tag" {
  description = "Tag used to identify the instance"
  type        = string
}

variable "config_source" {
  description = "Source of the CloudWatch agent configuration (local or s3)"
  type        = string
}

variable "local_config_file_path" {
  description = "Path to the local CloudWatch agent configuration file"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for CloudWatch agent configuration"
  type        = string
}

variable "s3_config_url" {
  description = "S3 URL for the CloudWatch agent configuration file"
  type        = string
}

variable "agent_installed_check_command" {
  description = "Command to check if CloudWatch agent is installed"
  type        = string
  default     = "command -v amazon-cloudwatch-agent"
}

variable "install_agent_command" {
  description = "Command to install CloudWatch agent"
  type        = string
  default     = "yum install -y amazon-cloudwatch-agent"
}

