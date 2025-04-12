# Data Migration Service Policy

data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com"]
      type        = "Service"
    }
  }
}

# Data Migration Service Role for Access to Source and Target endpoint
resource "aws_iam_role" "dms-access-for-endpoint" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-access-for-endpoint"
}



resource "aws_iam_role" "dms-vpc-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-vpc-role"
}

resource "aws_iam_role_policy_attachment" "dms-vpc-role-AmazonDMSVPCManagementRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = aws_iam_role.dms-vpc-role.name
}

# Create a new replication instance
resource "aws_dms_replication_instance" "dms_rep_instance" {
  count = 0
  allocated_storage            = 10
  apply_immediately            = true
  multi_az                     = false
  replication_instance_class   = "dms.t2.micro"
  replication_instance_id      = "startup-mvp-app"
  replication_subnet_group_id  = aws_dms_replication_subnet_group.dms_subnet_group.id

 tags = {
    Name = "${var.prefix}-dms-replication"
  }

  vpc_security_group_ids = [aws_security_group.dms_sg.id]

  depends_on = [
    aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole
  ]
}

# DMS Subnet Group 
resource "aws_dms_replication_subnet_group" "dms_subnet_group" {
  replication_subnet_group_description = "Replication subnet group"
  replication_subnet_group_id          = "dms-startup-mvp"

  subnet_ids = data.tfe_outputs.infra-connection.values.private_subnets

  tags = {
    Name = "${var.prefix}-dms-subnet-group"
  }
}

# DMS Secruity Group
resource "aws_security_group" "dms_sg" {
  name        = "DMS SG"
  description = "security group for DMS replication instance"
  vpc_id      = data.tfe_outputs.infra-connection.values.main_vpc

    egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}


# Source Endpoint -> EC2 Instance
/*resource "aws_dms_endpoint" "ec2_endpoint" {
  database_name               = "mvp"
  endpoint_id                 = "startup-webserver-app"
  endpoint_type               = "source"
  engine_name                 = "postgres"
  password                    = var.db_password
  port                        = 5432
  server_name                 = aws_instance.websever-app.private_ip
  ssl_mode                    = "none"

  tags = {
    Name = "${var.prefix}-ec2-endpoint"
  }

  username = var.db_username
}
*/


# Target Endpoint -> RDS (PostgreSQL)

resource "aws_dms_endpoint" "rds_endpoint" {
  database_name               = "mvp"
  endpoint_id                 = "startup-rds-db"
  endpoint_type               = "target"
  engine_name                 = "postgres"
  password                    = var.db_password
  port                        = 5432
  server_name                 = aws_db_instance.rds_app_db.address
  ssl_mode                    = "none"

  tags = {
    Name = "${var.prefix}-rds-endpoint"
  }

  username = var.db_username
}



# DMS Task

# Create a new replication task
/*resource "aws_dms_replication_task" "dms_task" {
  migration_type            = "full-load"
  replication_instance_arn  = aws_dms_replication_instance.dms_rep_instance.replication_instance_arn
  replication_task_id       = "replication-task-1"
  source_endpoint_arn       = aws_dms_endpoint.ec2_endpoint.endpoint_arn
  table_mappings            = "${file("mapping.json")}"

  tags = {
    Name = "${var.prefix}-dms-rep-task"
  }
  target_endpoint_arn = aws_dms_endpoint.rds_endpoint.endpoint_arn
}
*/
