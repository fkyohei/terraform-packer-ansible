#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Variables
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
variable "env" {}
variable "env_name" {}
variable "elastic_ip" {
    default = {
        step        = []
    }
}
variable "subnet_ids" {
    default = []
}
variable "security_group_ids" {
    default = {
        step        = []
    }
}
variable "ec2" {
    default = {
        step = {
            count           = ""
            ami_id          = ""
            instance_type   = ""
            key_name        = ""
            monitoring      = ""
            private_ip      = ""
            tags            = ""
        }
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# EC2
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
resource "aws_instance" "step" {
    count                   = var.ec2.step.count
    ami                     = var.ec2.step.ami_id
    instance_type           = var.ec2.step.instance_type
    key_name                = var.ec2.step.key_name
    monitoring              = var.ec2.step.monitoring
    vpc_security_group_ids  = var.security_group_ids.step
    subnet_id               = element(var.subnet_ids, (count.index % length(var.subnet_ids)))
    private_ip              = element(var.ec2.step.private_ip, count.index)
#    disable_api_termination = true
    disable_api_termination = false
    instance_initiated_shutdown_behavior = "stop"

    tags = {
        Name = "${element(var.ec2.step.tags, count.index)} - ${format("%02d", count.index + 1)} | ${var.env_name}"
    }
    volume_tags = {
        Name = "${element(var.ec2.step.tags, count.index)} - ${format("%02d", count.index + 1)} | ${var.env_name}"
    }
}

resource "aws_eip_association" "step_eip" {
    instance_id     = aws_instance.step.0.id
    allocation_id   = var.elastic_ip.step
}