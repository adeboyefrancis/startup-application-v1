# DB Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "start-up-db"
  subnet_ids = data.tfe_outputs.infra-connection.values.private_subnets

  tags = {
    Name = "${var.prefix}-mvp-app"
  }
}

# DB Instance
resource "aws_db_instance" "rds_app_db" {
  allocated_storage    = 10
  db_name              = "mvp"
  engine               = "postgres"
  engine_version       = "16.3"
  instance_class       = "db.t3.micro"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = aws_db_parameter_group.rds_para_group.name
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  multi_az = false
  skip_final_snapshot  = true
  
    tags = {
    Name = "${var.prefix}-mvp-rds-db"
  }
}

#Parameter Group
resource "aws_db_parameter_group" "rds_para_group" {
  name   = "rds-pg"
  family = "postgres16"


  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }
}


# RDS Security Group
resource "aws_security_group" "rds_sg" {
  description = "Allow Inbound Traffic from Webserver"
  name        = "${var.prefix}-rds-db-sg"
  vpc_id      = data.tfe_outputs.infra-connection.values.main_vpc

  ingress {
    security_groups = [aws_security_group.webserver-sg.id, aws_security_group.dms_sg.id]
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
  }

    tags = {
    Name = "${var.prefix}-rds-app-sg"
  }
}
