output "ec2_instance_web_ids" {
    value = [
        for instance in aws_instance.web:
        instance.id
    ]
}
output "ec2_instance_web_private_ips" {
    value = [
        for instance in aws_instance.web:
        instance.private_ip
    ]
}