Example Usage
Root Module main.tf

module "cloudwatch_agent" {
  source                = "./modules/cloudwatch_agent"
  ami_id                = "ami-0abcdef1234567890"
  instance_type         = "t2.micro"
  config_source         = "local"
  local_config_file_path = "./configs/amazon-cloudwatch-agent.json"
  s3_bucket_name        = "my-s3-bucket"
  s3_config_url         = "s3://my-s3-bucket/amazon-cloudwatch-agent.json"
}
Root Module variables.tf
hcl
Copy code
variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "config_source" {
  description = "Source of the CloudWatch Agent configuration file ('local' or 's3')"
  type        = string
  default     = "s3"
}

variable "local_config_file_path" {
  description = "Path to the local CloudWatch Agent configuration file"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket containing the CloudWatch Agent configuration file"
  type        = string
}

variable "s3_config_url" {
  description = "S3 URL for the CloudWatch Agent configuration file"
  type        = string
}
Outcome
The module dynamically decides whether to install the agent based on whether it’s already present.
It dynamically uses the configuration file from either a local path or an S3 bucket.
The implementation is reusable and customizable for different environments.





