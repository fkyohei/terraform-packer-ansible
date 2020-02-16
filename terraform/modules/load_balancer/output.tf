output "load_balancer_web_alb_dns_name" {
    value = aws_lb.web_alb.dns_name
}
output "load_balancer_web_alb_zone_id" {
    value = aws_lb.web_alb.zone_id
}