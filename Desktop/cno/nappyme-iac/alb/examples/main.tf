module "alb" {
  source              = "../"
  lb_name             = "nappyme-alb"
  lb_internal         = false
  load_balancer_type  = "application"
  environment         = "dev"
  tg_name             = "nappyme-alb-tag"
  tg_port             = 80
  tg_protocol         = "HTTP"
  target_type         = "instance"
  check_protocol      = "HTTP"
  path                = "/*"
  matcher             = "200,202"
  cluster_name        = "nappyme-tools"
  aws_region          = "eu-west-1"  
  lb_ip_address_type  = "ipv4"
  lb_idle_timeout     = 60
  listener_port       = 443
  listener_protocol   = "HTTP"
  vpc_name            = "nappyme-vpc"

}