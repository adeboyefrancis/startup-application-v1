output "webapp_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.websever-app.public_ip
}

output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.rds_app_db.address
  sensitive   = true
}
