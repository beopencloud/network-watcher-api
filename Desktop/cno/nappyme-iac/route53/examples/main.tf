
module "route53" {
  source        = "../"
  domain_name   = "www.nappyme"
  environment   = "dev"
  aws_region    = "eu-west-1"
}