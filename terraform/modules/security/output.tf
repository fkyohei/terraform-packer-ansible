output "security_group_step_servers_id" {
    value = aws_security_group.step_servers.id
}
output "security_group_from_step_servers_id" {
    value = aws_security_group.from_step_servers.id
}
output "security_group_web_alb_id" {
    value = aws_security_group.web_alb.id
}
output "security_group_web_servers_id" {
    value = aws_security_group.web_servers.id
}
output "security_group_rds_db_id" {
    value = aws_security_group.rds_db.id
}
output "security_group_redis_id" {
    value = aws_security_group.redis.id
}