provider "aws" {
    region          = var.aws_region
}

resource "aws_vpc" "nappyme_vpc" {
  cidr_block           = var.cidr_block_vpc
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = {
     Name              = "${var.vpc_name}-${var.environment}"
    "kubernetes.io/cluster/${var.cluster_name}-${var.environment}" = "shared"
  }
}

/*
### Public Subnets
Create two PublicSubnets for High Availability
They will host our ELB, NAT Gateway and facing to Internet
*/
resource "aws_subnet" "public_subnet_eks_1" {
  vpc_id            = aws_vpc.nappyme_vpc.id
  count             = length(var.public_subnets_eks_1) 
  cidr_block        = element(var.public_subnets_eks_1, count.index)
  availability_zone = element(var.availability_zones_0, count.index)
  map_public_ip_on_launch  = true
  depends_on = [ aws_vpc.nappyme_vpc ]
  tags              = {
     state          = "public"
    "kubernetes.io/cluster/${var.cluster_name}-${var.environment}" = "shared"
    "kubernetes.io/cluster/nappyme-tools" = "shared"
    "kubernetes.io/role/elb" = 1
     Name           = "eks-public-subnet-${count.index + 1}-${var.environment}"
  }

}

resource "aws_subnet" "public_subnet_eks_2" {
  vpc_id            = aws_vpc.nappyme_vpc.id
  count             = length(var.public_subnets_eks_2) 
  cidr_block        = element(var.public_subnets_eks_2, count.index)
  availability_zone = element(var.availability_zones_1, count.index)
  map_public_ip_on_launch  = true
  depends_on = [ aws_vpc.nappyme_vpc ]
  tags              = {
     state          = "public"
    "kubernetes.io/cluster/${var.cluster_name}-${var.environment}" = "shared"
    "kubernetes.io/cluster/nappyme-tools" = "shared"
    "kubernetes.io/role/elb" = 1
     Name           = "eks-public-subnet-${count.index + 2}-${var.environment}"
  }

}

/*
### Private Subnets
Create two Private Subnets for High Availability
They will host our EKS Cluster
*/
resource "aws_subnet" "private_subnet_eks_1" {
  count             = length(var.private_subnets_eks_1) 
  vpc_id            = aws_vpc.nappyme_vpc.id
  cidr_block        = element(var.private_subnets_eks_1, count.index)
  availability_zone = element(var.availability_zones_0, count.index)
  map_public_ip_on_launch = false
  depends_on        = [ aws_vpc.nappyme_vpc ]
  tags = {
    state           = "private"
    "kubernetes.io/cluster/${var.cluster_name}-${var.environment}" = "shared"
    "kubernetes.io/cluster/nappyme-tools" = "shared"
    "kubernetes.io/role/internal-elb" = 1
    Name            = "eks-subnet-${count.index + 1}-${var.environment}"
  }

}

resource "aws_subnet" "private_subnet_eks_2" {
  count             = length(var.private_subnets_eks_2)
  vpc_id            = aws_vpc.nappyme_vpc.id
  cidr_block        = element(var.private_subnets_eks_2, count.index)
  availability_zone = element(var.availability_zones_1, count.index)
  depends_on        = [ aws_vpc.nappyme_vpc ]
   map_public_ip_on_launch = false
  tags = {
    state           = "private"
    "kubernetes.io/cluster/${var.cluster_name}-${var.environment}" = "shared"
    "kubernetes.io/cluster/nappyme-tools" = "shared"
    "kubernetes.io/role/internal-elb" = 1
    Name            = "eks-subnet-${count.index + 2}-${var.environment}"
  }

}

/*
### Private Subnets
Create two Private Subnets for High Availability
They will host our RDS Database
*/
resource "aws_subnet" "private_subnet_rds_1" {
  count             = length(var.private_subnets_rds_1) 
  vpc_id            = aws_vpc.nappyme_vpc.id
  cidr_block        = element(var.private_subnets_rds_1, count.index)
  availability_zone = element(var.availability_zones_0, count.index)
  depends_on        = [ aws_vpc.nappyme_vpc ]
  tags = {
    state           = "private"
    Name            = "rds-${count.index + 1}-${var.environment}"
  }

}

resource "aws_subnet" "private_subnet_rds_2" {
  count             = length(var.private_subnets_rds_2)
  vpc_id            = aws_vpc.nappyme_vpc.id
  cidr_block        = element(var.private_subnets_rds_2, count.index)
  availability_zone = element(var.availability_zones_1, count.index)
  depends_on        = [ aws_vpc.nappyme_vpc ]
  tags = {
    state           = "private"
    Name            = "rds-${count.index + 2}-${var.environment}"
  }

}

/*
### Internet Gateway
Allow our Public Subnets to communicate with internet
We need to create an Internet Gateway and Associate it to the Public Subnet using Route Table
*/
resource "aws_internet_gateway" "igw" {
  vpc_id            = aws_vpc.nappyme_vpc.id
  depends_on        = [ aws_vpc.nappyme_vpc ]
  tags = {
    "Name"          = "eks-internet-gateway-${var.environment}"
  }
}

resource "aws_route_table" "internet_route" {
  vpc_id            = aws_vpc.nappyme_vpc.id
  route {
    cidr_block      = var.cidr_block-internet_gw
    gateway_id      = aws_internet_gateway.igw.id
  } 
  

  depends_on = [ aws_vpc.nappyme_vpc ]
  tags = {
    state           = "public"
    Name            = "eks-public_route_table-${var.environment}"
  }
}

resource "aws_route_table_association" "public-route-table-1" {
  count             = length(var.public_subnets_eks_1)
  subnet_id         = element(aws_subnet.public_subnet_eks_1.*.id, count.index)
  route_table_id    = aws_route_table.internet_route.id
  depends_on = [
    aws_route_table.internet_route, aws_subnet.public_subnet_eks_1
  ]
}

resource "aws_route_table_association" "public-route-table-2" {
  count             = length(var.public_subnets_eks_1)
  subnet_id         = element(aws_subnet.public_subnet_eks_2.*.id, count.index)
  route_table_id    = aws_route_table.internet_route.id
  depends_on = [
    aws_route_table.internet_route, aws_subnet.public_subnet_eks_2
  ]
} 

/*
### NAT Gateway
Allow our Private subnets used by EKS to Accss the internet
We need to create an Nat Gateway on the Public Subnets used by EKS
We Associate NAT Gateway with Private Subnets using Route Tables 
*/

resource "aws_eip" "nat_az0" {
  vpc               = true
  count             = length(var.private_subnets_eks_1)
  public_ipv4_pool  = "amazon"
}

resource "aws_nat_gateway" "nat_gateway_eks_1" {
  count             = length(var.private_subnets_eks_1)
  allocation_id     = element(aws_eip.nat_az0.*.id, count.index)
  subnet_id         = element(aws_subnet.public_subnet_eks_1.*.id, count.index)
//  depends_on        = [ aws_internet_gateway.igw ]
  tags              = {
    Name            = "eks-nat_Gateway-${count.index + 1}-${var.environment}"
  }
 }

resource "aws_route_table" "private_nat_eks_1" {
  vpc_id            = aws_vpc.nappyme_vpc.id
  count             = length(var.private_subnets_eks_1)
  route {
    cidr_block      = var.cidr_block_nat_gw_az0
    gateway_id      = element(aws_nat_gateway.nat_gateway_eks_1.*.id, count.index)
  }
  
//  depends_on = [ aws_vpc.nappyme_vpc ]
  tags = {
    Name            = "eks-nat_route_table-${count.index + 1 }-${var.environment}"
    state           = "public"
  }
}

resource "aws_route_table_association" "private-route-table-eks-1" {
  count             = length(var.private_subnets_eks_1)
  subnet_id         = element(aws_subnet.private_subnet_eks_1.*.id, count.index)
  route_table_id    = element(aws_route_table.private_nat_eks_1.*.id, count.index) 
  depends_on = [
    aws_route_table.private_nat_eks_1, aws_subnet.private_subnet_eks_1
  ]
}

resource "aws_eip" "nat_az1" {
  vpc               = true
  count             = length(var.private_subnets_eks_2)
  public_ipv4_pool  = "amazon"
}


resource "aws_nat_gateway" "nat_gateway_eks_2" {
  count             = length(var.private_subnets_eks_2)
  allocation_id     = element(aws_eip.nat_az1.*.id, count.index)
  subnet_id         = element(aws_subnet.public_subnet_eks_2.*.id, count.index)
//  depends_on        = [ aws_internet_gateway.igw ]
  tags              = {
    Name            = "eks-nat_Gateway-${count.index + 1}-${var.environment}"
  }
}


resource "aws_route_table" "private_nat_eks_2" {
  vpc_id            = aws_vpc.nappyme_vpc.id
  count             = length(var.private_subnets_eks_2)
  route {
    cidr_block      = var.cidr_block_nat_gw_az1
    gateway_id      = element(aws_nat_gateway.nat_gateway_eks_2.*.id, count.index)
  }
  
//  depends_on = [ aws_vpc.nappyme_vpc ]
  tags = {
    Name            = "eks-nat_route_table-${count.index + 1 }-${var.environment}"
    state           = "public"
  }
}


resource "aws_route_table_association" "private-route-table-eks-2" {
  count             = length(var.private_subnets_eks_2)
  subnet_id         = element(aws_subnet.private_subnet_eks_2.*.id, count.index)
  route_table_id    = element(aws_route_table.private_nat_eks_2.*.id, count.index)
  depends_on = [
    aws_route_table.private_nat_eks_2, aws_subnet.private_subnet_eks_2
  ]
}

resource "aws_security_group" "security_group_vpc" {
  name              = "VPC_SG_NAPPYME"
  description       = "Nappyme security group"
  vpc_id            = aws_vpc.nappyme_vpc.id
  ingress           {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress            {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
} 



resource "aws_network_acl" "eks-external-zone" {
  count = length(var.public_subnets_eks_1)
  vpc_id = aws_vpc.nappyme_vpc.id
  subnet_ids = [ element(aws_subnet.public_subnet_eks_1.*.id, count.index), element(aws_subnet.public_subnet_eks_2.*.id, count.index)]
  tags = {
    "Name" = "eks-external-zone-acl"
  }
}

resource "aws_network_acl_rule" "eks-ingress-external-zone-rules" {
  count = length(var.public_subnets_eks_1)
  network_acl_id = element(aws_network_acl.eks-external-zone.*.id, count.index)
  rule_number = 100
  egress = false
  protocol = "-1"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 0
  to_port = 0
}

resource "aws_network_acl_rule" "eks-egress-external-zone-rules" {
  count = length(var.public_subnets_eks_1)
  network_acl_id = element(aws_network_acl.eks-external-zone.*.id, count.index)
  rule_number = 100
  egress = true
  protocol = "-1"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 0
  to_port = 0
}

resource "aws_network_acl" "eks-internal-zone" {
  count = length(var.private_subnets_eks_1)
  vpc_id = aws_vpc.nappyme_vpc.id
  subnet_ids = [ element(aws_subnet.private_subnet_eks_1.*.id, count.index), element(aws_subnet.private_subnet_eks_2.*.id,count.index)]
  tags = {
    "Name" = "eks-internal-zone-acl"
  }
}

resource "aws_network_acl_rule" "ingress-internal-zone-rules" {
  count = length(var.public_subnets_eks_1)
  network_acl_id = element(aws_network_acl.eks-internal-zone.*.id, count.index )
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "egress-internal-zone-rules" {
  count = length(var.public_subnets_eks_1)
  network_acl_id = element(aws_network_acl.eks-internal-zone.*.id, count.index )
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

