output "rds-username" {
    description = "database username"
    value = "u${random_string.db_username.result}"
}

output "rds-password" {
    description = "database password"
    value = "p${random_string.db_password.result}"
}

output "private-rds-endpoint" {
    description = "The database endpoint"
    value = aws_db_instance.db_inst.address
}

output "sg-eks-cluster" {
    description = "The cluster security group"
    value = data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}

/*
output "sg-rds-access" {
    description = "The security group rds access"
    value = aws_security_group.RDS_SG.id
}*/