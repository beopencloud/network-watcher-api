module "cloudFront" {
  source = "../"
  bucket_name   = "bucket-nappyme-s3"
  aws_region    = "us-east-1"
  environment   = "dev"
  waf_name      = "waf_nappyme"
  scope         = "CLOUDFRONT"
}