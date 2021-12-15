

provider "aws" {
    region = var.region
}

data "aws_vpc" "nappyme_vpc" { 
    tags              = {
     Name           = "${var.vpc_name}-${var.environment}"
  }
}
data "aws_eks_cluster" "cluster" {
  name = var.cluster_id
}

data "aws_caller_identity" "current" {
  
}
data "aws_subnet" "private_subnet_eks_1" {
  tags = {
    state           = "private"
    Name           = "rds-1-${var.environment}"
  }
}

resource "aws_efs_file_system" "efs" {
  creation_token = var.token_creation
  tags = {
    Name = "${var.environment}-efs-nappyme"
  }
  availability_zone_name = data.aws_subnet.private_subnet_eks_1.availability_zone
}

resource "aws_efs_mount_target" "efs_mount" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id =  data.aws_subnet.private_subnet_eks_1.id
  security_groups = ["${aws_security_group.efs_securty_group.id}"]
}

resource "aws_efs_file_system_policy" "EFS_Policy" {
  file_system_id = aws_efs_file_system.efs.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Id": "ExamplePolicy01",
    "Statement": [
        {
            "Sid": "ExampleStatement01",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Resource": "${aws_efs_file_system.efs.arn}",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "true"
                }
            }
        }
    ]
})
}

resource "aws_security_group" "efs_securty_group" {
  name = "efs-security-group"
  description = "Allow efs traffic"
  vpc_id = data.aws_vpc.nappyme_vpc.id 
  ingress {
    description = "Inbound EFS traffic"
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    cidr_blocks      = [data.aws_vpc.nappyme_vpc.cidr_block]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
