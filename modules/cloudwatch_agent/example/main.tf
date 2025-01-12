module "cloudwatch_agent" {
  source                = "./modules/cloudwatch_agent"
  ami_id                = "ami-0abcdef1234567890"
  instance_type         = "t2.micro"
  instance_name_tag     = "CloudWatchAgentInstance"
  config_source         = "s3"
  local_config_file_path = "./configs/amazon-cloudwatch-agent.json"
  s3_bucket_name        = "my-cloudwatch-configs"
  s3_config_url         = "s3://my-cloudwatch-configs/amazon-cloudwatch-agent.json"
}
