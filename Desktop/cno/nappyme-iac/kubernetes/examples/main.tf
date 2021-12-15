module "kubernetes" {
  source                    = "../"
  region                    = "eu-west-1"
  cluster_name              = "nappyme-tools"
 // version                   = "v1.4.0"
  cluster_id                = "nappyme-tools-dev"
  environment               = "dev"
  vpc_name                  = "nappyme-vpc"
}