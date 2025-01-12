variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
}

variable "instance_name_tag" {
  description = "The tag name of the EC2 instance"
  type        = string
}

variable "config_source" {
  description = "The source of the CloudWatch Agent configuration (either 's3' or 'local')"
  type        = string
  default     = "s3"
}

variable "local_config_file_path" {
  description = "The local path of the CloudWatch agent configuration file"
  type        = string
  default     = "./configs/amazon-cloudwatch-agent.json"
}

variable "s3_bucket_name" {
  description = "The S3 bucket name where the CloudWatch Agent configuration file is stored"
  type        = string
}

variable "s3_config_key" {
  description = "The S3 key for the CloudWatch Agent configuration file"
  type        = string
}


