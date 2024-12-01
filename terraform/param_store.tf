# Parameter Store for Database Values

resource "aws_ssm_parameter" "db_secret_key" {
  name        = "/cloudtalents/startup/db_secret_key"
  type        = "SecureString"
  value       = var.secret_key
}

resource "aws_ssm_parameter" "db_username" {
  name        = "/cloudtalents/startup/db_username"
  type        = "String" 
  value       = var.db_username
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/cloudtalents/startup/db_password"
  type        = "SecureString"
  value       = var.db_password
}

resource "aws_ssm_parameter" "rds_endpoint" {
  name        = "/cloudtalents/startup/database_endpoint"
  type        = "String"
  value       = var.db_endpoint
}

resource "aws_ssm_parameter" "s3_rds_bucket" {
  name        = "/cloudtalents/startup/image_storage_bucket_name"
  type        = "String"
  value       = var.s3_name
}

resource "aws_ssm_parameter" "cfd_image_domain" {
  name        = "/cloudtalents/startup/image_storage_cloudfront_domain"
  type        = "String"
  value       = var.cfd_domain
}
