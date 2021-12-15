

provider "aws" {
    region          = var.aws_region
}

data "aws_vpc" "nappyme_vpc" { 
    tags              = {
     Name           = "${var.vpc_name}-${var.environment}"
  }
}

data "aws_subnet" "public_subnet_eu_west_1a" {
  tags              = {
     state          = "public"
    "kubernetes.io/cluster/${var.cluster_name}-${var.environment}" = "shared"
    "kubernetes.io/role/elb" = 1
     Name           = "node-group-subnet-1-${var.environment}"
  }
}


data "aws_subnet" "public_subnet_eu_west_1b" {
  tags              = {
     state          = "public"
    "kubernetes.io/cluster/${var.cluster_name}-${var.environment}" = "shared"
    "kubernetes.io/role/elb" = 1
     Name           = "node-group-subnet-2-${var.environment}"
  }
}

resource "aws_lb" "nappyme_lb" {
  name               =  var.lb_name
  internal           =  var.lb_internal
  load_balancer_type =  var.load_balancer_type
//  security_groups    =  data.aws_security_group.security_group_vpc.id
  subnets            =  [data.aws_subnet.public_subnet_eu_west_1a.id, data.aws_subnet.public_subnet_eu_west_1b.id ]
  idle_timeout       =  var.lb_idle_timeout
  ip_address_type    =  var.lb_ip_address_type
  tags              = {
    Name            = "alb-nappyme"
  }
}


resource "aws_lb_listener" "lb_listner" {
  load_balancer_arn  = aws_lb.nappyme_lb.arn
  port               = var.listener_port
  protocol           = var.listener_protocol
//  ssl_policy         = var.listener_ssl_policy
//  certificate_arn    = data.aws_acm_certificate.certificate.arn
default_action {
  target_group_arn = aws_lb_target_group.lb_target_group.arn
  type = "forward"
}
}


resource "aws_lb_target_group" "lb_target_group" {
  name               = var.tg_name
  port               = var.tg_port
  protocol           = var.tg_protocol
  vpc_id             = data.aws_vpc.nappyme_vpc.id
  target_type        = var.target_type
  health_check {
    path             = var.path
    protocol         = var.check_protocol 
    matcher          = var.matcher
  }
}

/*
resource "aws_lb_listener_rule" "lb_rule" {
  listener_arn       = aws_lb_listener.lb_listner.arn
  priority           = 1
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}
*/