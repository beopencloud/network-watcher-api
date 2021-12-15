
provider "aws" {
    region = var.aws_region
}

data "aws_cloudfront_distribution" "nappyme_cloudfront" {
  id = "E1NWI3NQX5GA4W"
}

resource "aws_route53_zone" "zone_public" {
  name            = "${var.domain_name}.com"
    tags = {
    "Name" = "${var.environment}-public-zone-nappyme"
  }
}

resource "aws_route53_record" "nappyme_route53" {
  zone_id = aws_route53_zone.zone_public.zone_id
  name = "${var.domain_name}.com"
  type = "A"
  alias {
    name = data.aws_cloudfront_distribution.nappyme_cloudfront.domain_name
    zone_id = data.aws_cloudfront_distribution.nappyme_cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}
