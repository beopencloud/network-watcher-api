data "aws_availability_zones" "available" { }



module "vpc" {
  source                    = "../"
  aws_region                = "eu-west-1"
  cidr_block_vpc            = "10.0.0.0/16"
  public_subnets_eks_1      = ["10.0.6.0/23"]
  public_subnets_eks_2      = ["10.0.8.0/23"]
  private_subnets_eks_1     = ["10.0.0.0/23"]
  private_subnets_eks_2     = ["10.0.2.0/23"]
  private_subnets_rds_1     = ["10.0.4.0/24"]
  private_subnets_rds_2     = ["10.0.5.0/24"]
  availability_zones_0      = ["eu-west-1a"]
  availability_zones_1      = ["eu-west-1b"]
  cidr_block_nat_gw_az0     = "0.0.0.0/0"
  cidr_block_nat_gw_az1     = "0.0.0.0/0"
  cidr_block-internet_gw    = "0.0.0.0/0"
  environment               = "dev" 
  vpc_name                  = "nappyme-vpc"
  cluster_name              = "nappyme-tools"
}