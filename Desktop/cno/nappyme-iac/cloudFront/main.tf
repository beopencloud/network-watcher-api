
provider "aws" {
    region = var.aws_region
}

data "aws_s3_bucket" "nappyme_bucketS3" {
  bucket =var.bucket_name
}

data "aws_wafv2_web_acl" "waf" {
  name = var.waf_name
  scope = var.scope
}

resource "aws_cloudfront_distribution" "nappyme_cloudfront" {
  origin {
    domain_name = data.aws_s3_bucket.nappyme_bucketS3.bucket_domain_name
    origin_id = var.bucket_name
  }
  enabled = true
  is_ipv6_enabled = true
  comment = "cloudfront for route53"
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods = [ "DELETE" , "GET", "HEAD", "OPTIONS", "PATCH", "PUT", "POST"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = var.bucket_name
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }
  ordered_cache_behavior {
    path_pattern = "/content/immutable/*"
    allowed_methods = [ "GET", "HEAD", "OPTIONS" ]
    cached_methods = [ "GET", "HEAD", "OPTIONS" ]
    target_origin_id = var.bucket_name
    forwarded_values {
      query_string = false
      headers = [ "Origin" ]
      cookies {
        forward = "none"
      }
    }
    min_ttl = 0
    default_ttl = 86400
    max_ttl = 31536000
    compress = true
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern = "/content/*"
    allowed_methods = [ "GET", "HEAD", "OPTIONS" ]
    cached_methods = [ "GET", "HEAD" ]
    target_origin_id = var.bucket_name
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 84600
    compress = true
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations = [ "US", "CA", "GB", "DE" ]
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  price_class = "PriceClass_200"
  tags = {
    "Name" = "cloudfront-nappyme-${var.environment}"
  }
}

resource "aws_cloudfront_distribution" "cloudFront_nappyme" {
  web_acl_id = data.aws_wafv2_web_acl.waf.arn


  origin {
    domain_name = data.aws_s3_bucket.nappyme_bucketS3.bucket_domain_name
    origin_id = "S3-${data.aws_s3_bucket.nappyme_bucketS3.bucket}"
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }
   # By default, show index.html file
  default_root_object = "index.html"
  enabled = true
  # If there is a 404, return index.html with a HTTP 200 Response
  custom_error_response {
        error_caching_min_ttl = 3000
        error_code = 404
        response_code = 200
        response_page_path = "/index.html"
    }
  default_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods = ["GET", "HEAD"]
     target_origin_id = "S3-${data.aws_s3_bucket.nappyme_bucketS3.bucket}"
      # Forward all query strings, cookies and headers
      forwarded_values {
        query_string = true
        cookies {
          forward = "none"
        }
      }
      viewer_protocol_policy = "allow-all"
      min_ttl = 0
      default_ttl = 3600
      max_ttl = 86400
  }
  # Distributes content to US and Europe
  price_class = "PriceClass_100"
  # Restricts who is able to access this content
  restrictions {
    geo_restriction {
            # type of restriction, blacklist, whitelist or none
            restriction_type = "none"
    }
  }
  # SSL certificate for the service.
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}