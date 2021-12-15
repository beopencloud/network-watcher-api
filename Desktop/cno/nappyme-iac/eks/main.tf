provider "aws" {
    region          = var.aws_region
}

data "aws_vpc" "nappyme_vpc" { 
    tags              = {
     Name           = "${var.vpc_name}-${var.environment}"
  }
}

data "aws_subnet" "public_subnet_eks_1" {
  tags              = {
     state          = "public"
    "kubernetes.io/cluster/${var.cluster_name}-${var.environment}" = "shared"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
     Name           = "eks-public-subnet-1-${var.environment}"
  }
}

data "aws_subnet" "public_subnet_eks_2" {
  tags              = {
     state          = "public"
    "kubernetes.io/cluster/${var.cluster_name}-${var.environment}" = "shared"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
     Name           = "eks-public-subnet-2-${var.environment}"
  }
}

data "aws_subnet" "private_subnet_eks_1" {
  tags = {
    state           = "private"
    "kubernetes.io/cluster/${var.cluster_name}-${var.environment}" = "shared"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
    Name            = "eks-subnet-1-${var.environment}"
  }
}

data "aws_subnet" "private_subnet_eks_2" {
  tags = {
    state           = "private"
    "kubernetes.io/cluster/${var.cluster_name}-${var.environment}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
    Name            = "eks-subnet-2-${var.environment}"
  }
}

resource "aws_eks_cluster" "nappyme_cluster" {
  name              = "${var.cluster_name}-${var.environment}"
  role_arn          = aws_iam_role.eks_cluster_role.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  vpc_config {
    subnet_ids             = [data.aws_subnet.public_subnet_eks_1.id , data.aws_subnet.public_subnet_eks_2.id ,data.aws_subnet.private_subnet_eks_1.id , data.aws_subnet.private_subnet_eks_2.id ]
  //  security_group_ids     = [ aws_security_group.eks_cluster.id ]
    endpoint_private_access= true
    endpoint_public_access = true
  //  public_access_cidrs = [ "" ]
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy
  ]
  tags = {
    Name            = "${var.cluster_name}-${var.environment}-eks-master"
    }
  
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-cluster-role"
  description = "Allow cluster to manage node groups, fargate node and cloudWatch logs"
 // force_detach_policies =  true 
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "eks.amazonaws.com"
          ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role = aws_iam_role.eks_cluster_role.name
}

/*
Security Group Cluster
Allow communication between Control Plan and Data Plan
*/

resource "aws_security_group" "eks_cluster" {
  name        = "EKS_SG_NAPPYME/ControlPlaneSecurityGroup"
  description = "Allow communication between the control Plan and the Worker Nodes"
  vpc_id      = data.aws_vpc.nappyme_vpc.id
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  tags = {
    Name = "nappyme-sg-eks/ControlPlaneSecurityGroup"
  }
}

/*
Security Group For not Managed Nodes
Allow communication between Controle Plan and Node Managed Nodes
*/

/*
resource "aws_security_group_rule" "cluster_inbound" {
  description = "Allow unmanaged nodes to communicate with control plane (all ports)"
  from_port = 0
  to_port = 0
  protocol = "-1"
  security_group_id = aws_eks_cluster.nappyme_cluster.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.eks_nodes.id
  type = "ingress"
}

*/
resource "aws_eks_node_group" "eks_node_group_private" {
    cluster_name          = aws_eks_cluster.nappyme_cluster.name
    node_group_name       = "private-${var.cluster_name}-${var.environment}-node_group"
    node_role_arn         = aws_iam_role.eks_node_group_role.arn
    subnet_ids            = [ data.aws_subnet.private_subnet_eks_1.id , data.aws_subnet.private_subnet_eks_2.id ]
    scaling_config {
        desired_size      = var.desired_size
        max_size          = var.max_size
        min_size          = var.min_size
    }
    timeouts {
      delete = "30m"
      create = "30m"
    }
    instance_types = var.eks_node_group_instance_types
    depends_on = [
        aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
        aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]
    tags = { 
      Name                 = "${var.cluster_name}-${var.environment}-private-node-group"
    }
}

resource "aws_eks_node_group" "eks_node_group_public" {
    cluster_name          = aws_eks_cluster.nappyme_cluster.name
    node_group_name       = "public-${var.cluster_name}-${var.environment}-node_group"
    node_role_arn         = aws_iam_role.eks_node_group_role.arn
    subnet_ids            = [ data.aws_subnet.public_subnet_eks_1.id , data.aws_subnet.public_subnet_eks_2.id ]
    scaling_config {
        desired_size      = var.desired_size
        max_size          = var.max_size
        min_size          = var.min_size
    }
    timeouts {
      delete = "30m"
      create = "30m"
    }
    instance_types = var.eks_node_group_instance_types
    depends_on = [
        aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
        aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]
    tags = { 
      Name                 = "${var.cluster_name}-${var.environment}-public-node-group"
    }
}


/*
IAM ROLE EKS Node Group
*/
resource "aws_iam_role" "eks_node_group_role" {
  name               = "${var.cluster_name}-node-group-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn =  "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role =  aws_iam_role.eks_node_group_role.name 
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role =  aws_iam_role.eks_node_group_role.name 
}

resource "aws_iam_role_policy" "NodeGroupClusterAutoscalerPolicy" {
  name = "eks-cluster-auto-scaler"
  role = aws_iam_role.eks_node_group_role.id
  policy = jsonencode({
        Version = "2012-10-17"
    Statement = [
      {
        Action = [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:DescribeTags",
            "autoscaling:SetDesiredCapacity",
            "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


/*
Security Group Node
Allow communication between All nodes in the Cluster
*/

/*
resource "aws_security_group" "eks_nodes" {
  name        = "SG_NODE_GROUP_NAPPYME/ClusterSharedNodeSecurityGroup"
  description = "Communication between all nodes in the cluster"
  vpc_id      = data.aws_vpc.nappyme_vpc.id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self = true
  }
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    security_groups = [ aws_eks_cluster.nappyme_cluster.vpc_config[0].cluster_security_group_id ]
  }
    #Allow POD_SG to connect to NODE_GROUP_SG using TCP 53
    
  ingress {
    from_port = 53
    to_port   = 53
    protocol  = "tcp"
    security_groups = [aws_eks_cluster.nappyme_cluster.vpc_config[0].cluster_security_group_id]
  }

  #Allow POD_SG to connect to NODE_GROUP_SG using UDP 53
  ingress {
    from_port = 53
    to_port   = 53
    protocol  = "udp"
    security_groups = [ aws_eks_cluster.nappyme_cluster.vpc_config[0].cluster_security_group_id ]
   }
   

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "nappyme-sg-node/ControlPlaneSecurityGroup"
  }
}
/*
/*
resource "aws_security_group" "POD_SG" {
  name        = "SG_POD_SG"
  description = "Allow RDS  Access from Kubernetes POD"
  vpc_id      = data.aws_vpc.nappyme_vpc.id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = [ aws_eks_cluster.nappyme_cluster.vpc_config[0].cluster_security_group_id ]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

 
  tags = {
    Name = "pod-sg-${var.environment}"
  }
}
*/

resource "aws_security_group" "RDSDbAccessSGPod" {
  name        = "RDSDbAccessSGPod"
  description = "Allow communication between the control Plan and the Worker Nodes"
  vpc_id      = data.aws_vpc.nappyme_vpc.id
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  tags = {
    Name = "nappyme-sg-eks/ControlPlaneSecurityGroup"
  }
}