output "ec2_instance_step_ids" {
    value = [
        for instance in aws_instance.step:
        instance.id
    ]
}