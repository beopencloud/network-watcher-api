

module "eks" {
  source                        = "../"
  cluster_name                  = "nappyme-tools"
  environment                   = "dev"
  fargate_namespace             = "kube-system"
  desired_size                  = 1
  max_size                      = 2
  min_size                      = 1
  eks_node_group_instance_types = ["i3en.large"]
  aws_region                    = "eu-west-1"
  vpc_name                      = "nappyme-vpc" 
  db_instance_identifier        = "rds-instance-nappyme"
  name                          = "mydb"
}