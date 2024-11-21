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
  default = "v1.0.1"

}

variable "instance_type" {
  default = "t2.micro"
}
