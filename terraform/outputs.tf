output "webapp_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.websever-app.public_ip
}
