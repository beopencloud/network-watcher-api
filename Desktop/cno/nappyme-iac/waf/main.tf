
provider "aws" {
    region = "us-east-1"
}

/*
resource "aws_cloudwatch_metric_alarm" "neppyme-cloudWatch" {
  alarm_name          = "nappyme-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "neppyme-cloudWatch"
  statistic           = "Average"
  period              = "120"
  namespace           = "AWS/EC2"
}
*/

resource "aws_wafv2_web_acl" "waf" {
  name                = var.name
  scope               = "CLOUDFRONT"
  description         = var.description
  default_action {
    block {}
  }
  rule {
    name              = var.name_rule_ddos
    priority          = var.priority_ddos
    action {
      count {}
    }
    statement {
      rate_based_statement {
        limit         = var.limit_request
        aggregate_key_type = var.aggregate_key_type
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled  = var.cloudwatch_metrics_enabled
      metric_name                 = "neppyme-cloudWatch"
      sampled_requests_enabled    = var.sampled_requests_enabled
  }
  }
  rule {
    action {
      block {}
    }
    name            = var.name_rule_xss
    priority        = var.priority_xss
    statement {
      rate_based_statement {
        limit       = var.limit_request
        aggregate_key_type = var.aggregate_key_type
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled  = var.cloudwatch_metrics_enabled
      metric_name                 = "nappyme-cloudWatch"
      sampled_requests_enabled    = var.sampled_requests_enabled
  }
  }

  visibility_config {
    cloudwatch_metrics_enabled  = var.cloudwatch_metrics_enabled
    metric_name                 = "neppyme-cloudWatch"
    sampled_requests_enabled    = var.sampled_requests_enabled
  }
}

// associate waf to application loab balancer
/*
resource "aws_wafv2_web_acl_association" "waf_associate_alb" {
  resource_arn = data.aws_lb.nappyme_lb.arn
  web_acl_arn = aws_wafv2_web_acl.waf.arn
}
*/