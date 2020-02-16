#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Variables
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
variable "env" {}
variable "env_name" {}
variable "subnet_ids" {
    default = []
}
variable "security_group_ids" {
    default = {
        web = []
    }
}
variable "ec2" {
    default = {
        web = {
            count                   = ""
            ami_id                  = "" 
            instance_type           = ""
            key_name                = ""
            monitoring              = ""
            private_ip              = ""
            tags                    = ""
            iam_instance_profile    = ""
        }
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# EC2
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
resource "aws_instance" "web" {
    count                   = var.ec2.web.count
    ami                     = var.ec2.web.ami_id
    instance_type           = var.ec2.web.instance_type
    key_name                = var.ec2.web.key_name
    monitoring              = var.ec2.web.monitoring
    vpc_security_group_ids  = var.security_group_ids.web
    subnet_id               = element(var.subnet_ids, (count.index % length(var.subnet_ids)))
    private_ip              = element(var.ec2.web.private_ip, count.index)
    iam_instance_profile    = var.ec2.web.iam_instance_profile
#    disable_api_termination = true
    disable_api_termination = false
    instance_initiated_shutdown_behavior = "stop"

    tags = {
        Name = "${element(var.ec2.web.tags, count.index)} - ${format("%02d", count.index + 1)} | ${var.env_name}"
    }
    volume_tags = {
        Name = "${element(var.ec2.web.tags, count.index)} - ${format("%02d", count.index + 1)} | ${var.env_name}"
    }
}