module "s3" {
  source        = "../"
  environment   = "dev"
  bucket_name   = "bucket-nappyme-s3"
  acl           = "authenticated-read"
  aws_region    = "us-east-1"
}