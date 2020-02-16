#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Variables
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
variable "env_name" {}
variable "vpc_id" {}
variable "subnet_ids" {
    default = []
}
variable "security_group_ids" {
    default = {
        web_alb = ""
    }
}
variable "ec2_instance_ids" {
    default = {
        web         = []
    }
}
variable "alb" {
    default = {
        ssl_policy      = ""
        certificate_arn = ""
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Application Load Balancer
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
resource "aws_lb" "web_alb" {
    name                = "WebALB-${var.env_name}"
    internal            = false
    load_balancer_type  = "application"
    subnets             = var.subnet_ids
    security_groups = [
        var.security_group_ids.web_alb
    ]
}

resource "aws_lb_target_group" "web" {
    name     = "${var.env_name}-ALB-WEB"
    port     = 80
    protocol = "HTTP"
    vpc_id   = var.vpc_id

    health_check {
        interval            = 30
        path                = "/health.html"
        port                = 80
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
        matcher             = 200
    }
}

resource "aws_lb_target_group_attachment" "web" {
    count               = length(var.ec2_instance_ids.web)
    target_group_arn    = aws_lb_target_group.web.arn
    target_id           = element(var.ec2_instance_ids.web, count.index)
    port                = 80
}

resource "aws_lb_listener" "web_80" {
    load_balancer_arn   = aws_lb.web_alb.arn
    port                = "80"
    protocol            = "HTTP"

    default_action {
        type                = "forward"
        target_group_arn    = aws_lb_target_group.web.arn
    }
}

resource "aws_lb_listener" "web_443" {
    load_balancer_arn   = aws_lb.web_alb.arn
    port                = "443"
    protocol            = "HTTPS"
    ssl_policy          = var.alb.ssl_policy
    certificate_arn     = var.alb.certificate_arn

    default_action {
        type                = "forward"
        target_group_arn    = aws_lb_target_group.web.arn
    }
}