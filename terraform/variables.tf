# Prefix tagging resources

variable "prefix" {
  description = "Prefix for resources in AWS"
  default     = "tch-dev"
}

variable "project" {
  description = "Project name for tagging resources"
  default     = "dev-vm"
}

variable "contact" {
  description = "Contact email for tagging resources"
  default     = "adeboye.francis@icloud.com"
}

variable "region" {
  description = "Primary resource region"
  default     = "eu-west-1"

}

variable "custom_ami_version" {
  type = string
  description = "Custom AMI version"
  default = "v1.0.3"

}

variable "instance_type" {
  default = "t2.micro"
}

variable "db_username" {
  type = string
  sensitive = true
  
}
variable "db_password" {
  type        = string
  sensitive   = true
}


variable "s3_name" {
  type = string
}


variable "secret_key" {
  type = string
}

variable "db_endpoint" {
  type = string
}

variable "cfd_domain" {
  type = string
}
