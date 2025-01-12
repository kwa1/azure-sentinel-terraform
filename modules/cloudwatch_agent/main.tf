# EC2 instance resource
resource "aws_instance" "cloudwatch_agent_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  user_data     = templatefile("${path.module}/cloudwatch_agent_userdata.tpl", {
    agent_installed_check   = var.agent_installed_check_command
    install_agent_command   = var.install_agent_command
    config_source_condition = var.config_source == "local" ? "file" : "s3"
    config_file_path        = var.config_source == "local" ? var.local_config_file_path : var.s3_config_url
  })

  tags = {
    Name = "CloudWatch Agent Instance"
  }
}

# S3 bucket object for config (if config_source is S3)
resource "aws_s3_bucket_object" "cloudwatch_agent_config" {
  count  = var.config_source == "s3" ? 1 : 0
  bucket = var.s3_bucket_name
  key    = "amazon-cloudwatch-agent.json"
  source = var.local_config_file_path
}
