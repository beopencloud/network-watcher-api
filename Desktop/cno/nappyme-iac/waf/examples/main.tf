module "waf" {
  source             = "../"
  name               = "waf_nappyme"
  scope              = "REGIONAL"
  description        = "This is an WAF for nappyme project"
  aws_region         = "eu-west-1"
}