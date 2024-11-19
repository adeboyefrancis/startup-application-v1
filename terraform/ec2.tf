####################################
# Fetch Custom AMI created by Packer
####################################
/*
data "aws_ami" "custom_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["start_up_application_AMI-${var.custom_ami_version}"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
*/
# Fetch Outputs of Public Subnets from Infrastruction Network Connection Workspace
data "tfe_outputs" "infra-connection" {
  organization = "touchedbyfrancisblog"
  workspace    = "infra-connection"
}

#####################################
# Startup Application Virtual Machine
#####################################
resource "aws_instance" "websever-app" {
  ami                         = "ami-03b772fec0c152817"
  instance_type               = var.instance_type
  subnet_id                   = data.tfe_outputs.infra-connection.values.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.webserver-sg.id]

  tags = {
    Name = "${var.prefix}-startup-app"
  }
}

##############################
# Security Group for Webserver
##############################

resource "aws_security_group" "webserver-sg" {
  description = "Access to webserver on port 80 HTTP"
  name        = "${local.prefix}-startup-app-sg"
  vpc_id      = data.tfe_outputs.infra-connection.values.main_vpc

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}
