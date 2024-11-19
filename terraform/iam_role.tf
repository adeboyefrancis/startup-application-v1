###############################
# IAM Role for Instance Profile
###############################

resource "aws_iam_role" "ec2_role_ssm" {
  name = "EC2ConnectionSSM"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name    = "${var.prefix}-ec2-role-ssm"
  }
}

#############
# SSM Policy
#############

resource "aws_iam_policy" "ssm_policy" {
  name        = "ec2_ssm_policy"
  description = "Session Manager for Instance Connection"
  policy      = "${file("ssm_policy.json")}"
}

###################
# Policy Attachment
###################

resource "aws_iam_policy_attachment" "ssm_policy_attach" {
  name       = "ssm policy"
  roles      = [aws_iam_role.ec2_role_ssm.name]
  policy_arn = aws_iam_policy.ssm_policy.arn
}

##################
# Instance Profile 
##################
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2ConnectionSSM"
  role = aws_iam_role.ec2_role_ssm.name
}
