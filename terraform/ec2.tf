####################################
# Fetch Custom AMI created by Packer
####################################

data "aws_ami" "custom_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["startup-app-ami-tchbg-*"]
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

# Fetch Outputs of Public Subnets from Infrastruction Network Connection Workspace
data "tfe_outputs" "infra-connection" {
  organization = "touchedbyfrancisblog"
  workspace    = "infra-connection"
}

#####################################
# Startup Application Virtual Machine
#####################################
resource "aws_instance" "websever-app" {
  ami                         = data.aws_ami.custom_ami.id
  instance_type               = var.instance_type
  subnet_id                   = data.tfe_outputs.infra-connection.values.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.webserver-sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name    = "${var.prefix}-webserver-app-${var.custom_ami_version}"
    Version = var.custom_ami_version
  }
}

##############################
# Security Group for Webserver
##############################

resource "aws_security_group" "webserver-sg" {
  description = "Access to webserver on port 80 HTTP"
  name        = "${var.prefix}-startup-app-sg"
  vpc_id      = data.tfe_outputs.infra-connection.values.main_vpc

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  #DMS Inbound Traffic for Replication
    ingress {
    security_groups = [aws_security_group.dms_sg.id]
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
  }


  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}
