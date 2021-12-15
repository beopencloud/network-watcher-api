
module "kubernetes" {
  source                    = "../"
  region                    = "eu-west-1"
  token_creation            = "nappyme"
  environment               = "dev"
  cluster_name              = "nappyme-tools"
  cluster_id                = "nappyme-tools-dev"
  vpc_name                  = "nappyme-vpc"
}

