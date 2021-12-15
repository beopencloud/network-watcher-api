data "aws_ecr_authorization_token" "token" {
  
}

module "ecr" {
  source               = "../"
  repository_name      = "nappyme"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = false
  aws_region           = "eu-west-1"
  environment          = "dev"
  lifecycle_policy     = "${file("lifecycle-policy.json")}"
  repository_policy    = "${file("repository-policy.json")}"
}