provider "aws" {
    region          = var.aws_region
}

data "aws_subnet" "private_subnet_rds_1" {
  tags              = {
     state          = "private"
     Name           = "rds-1-${var.environment}"
  }
}
data "aws_subnet" "private_subnet_rds_2" {
  tags              = {
     state          = "private"
     Name           = "rds-2-${var.environment}"
  }
}

data "aws_vpc" "nappyme_vpc" { 
    tags            = {
     Name           = "${var.vpc_name}-${var.environment}"
  }
}
data "aws_eks_cluster" "cluster" {
  name = var.cluster_id
}
data "aws_caller_identity" "current" {
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id
}

data "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-cluster-role"
}

data "aws_security_group" "RDSDbAccessSGPod" {
  name = "RDSDbAccessSGPod"
}

resource "random_string" "db_username" {
  length = 12
  special = false
  upper = true
}

resource "random_string" "db_password" {
  length = 12
  special = false
  upper = true
}

resource "aws_db_instance" "db_inst" {
  engine                   = var.engine
  engine_version           = var.engine_version
  name                     = var.name
  identifier               = var.identifier
  //username          = "u${random_string.db_username.result}"
  //password          = "p${random_string.db_password.result}"
  username = var.username
  password = var.password
  instance_class           = var.instance_class
  allocated_storage        = var.allocated_storage
  storage_type             = var.storage_type
//  mmax_allocated_storage = var.mmax_allocated_storage 
  db_subnet_group_name     = aws_db_subnet_group.db_sub_group.id
  publicly_accessible      = false
  vpc_security_group_ids   = [ aws_security_group.RDS_SG.id ]
  port                     = var.rds_port
  multi_az = false
  iam_database_authentication_enabled = true
  deletion_protection      = var.deletion_protection
  storage_encrypted        = true
// kms_key_id              = var.kms_key_id
  backup_retention_period  = 14
  backup_window            = "03:00-04:00"
  final_snapshot_identifier= "postgresql-final-snapshot"
  skip_final_snapshot      = false
  delete_automated_backups = true
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.identifier)
    },
  )

}

resource "aws_db_subnet_group" "db_sub_group" {
  name       = var.db_subnet_group_name
  subnet_ids = [data.aws_subnet.private_subnet_rds_1.id, data.aws_subnet.private_subnet_rds_2.id]
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.db_subnet_group_name)
    },
  )
}

/*
Security Group VPC
*/

resource "aws_security_group" "RDS_SG" {
  name          = "RDS_SG"
  description   = "Allow inboun/outbound traffic"
  vpc_id        = data.aws_vpc.nappyme_vpc.id
  
  # Allow POD to connect to The RDS instance Database
  ingress {
    from_port       = var.rds_port
    to_port         = var.rds_port
    protocol        = "tcp"
    security_groups = [ data.aws_security_group.RDSDbAccessSGPod.id ]
  }

  tags = { 
    Name        = "rds-sg-nappyme"
  }
}


data "tls_certificate" "auth" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "main" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.auth.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}


resource "aws_iam_role" "AmazonEKS_RDS_IAMRole" {
  name        = "AmazonEKS_RDS_IAMRole"
  description = "Permissions required by the Kubernetes AWS ALB Ingress controller to do it's job."

  force_detach_policies = true

  assume_role_policy = <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:default:rds-db-access-nappyme"
        }
      }
    }
  ]
}
ROLE
}


# Role IAM to autorize kubernetes pod to access to the rds database
resource "aws_iam_policy" "RDS_ACCESS_FROM_K8S_POD" {
  name = "RDS_ACCESS_POLICY"
  policy = jsonencode(
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Action": [
             "rds-db:connect"
         ],
         "Resource": [
             "arn:aws:rds:${var.aws_region}:${data.aws_caller_identity.current.account_id}:db:${aws_db_instance.db_inst.resource_id}/${var.username}"
         ]
      }
   ]
})
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_EFS_CSI_Driver_Policy_attachment" {
  policy_arn = aws_iam_policy.RDS_ACCESS_FROM_K8S_POD.arn
  role = aws_iam_role.AmazonEKS_RDS_IAMRole.name
}



provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.cluster.token
}

resource "kubernetes_service_account" "alb_ingress_controller" {
  automount_service_account_token = true
  metadata {
    name      = "rds-db-access-nappyme"
    namespace = "default"
    labels    = {
      "role"       = "backend"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.AmazonEKS_RDS_IAMRole.arn
  //    "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/kubernetes/aws-alb-ingress-controller"
    }
}
}