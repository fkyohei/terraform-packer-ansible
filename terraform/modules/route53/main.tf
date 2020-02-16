#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Variables
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
variable "env_name" {}
variable "vpc_id" {}
variable "route53" {
    default = {
        zone_name = {
            public  = ""
            private = ""
        }
        record_name = {
            public = {
                web    = ""
            }
        }
    }
}
variable "ec2" {
    default = {
        private_ip = {
            web         = []
        }
    }
}
variable "load_balancer" {
    default = {
        web = {
            dns_name = ""
            zone_id  = ""
        }
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Route53
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
resource "aws_route53_zone" "public" {
    name      = var.route53.zone_name.public
    comment   = var.env_name
}

resource "aws_route53_zone" "private" {
    name      = var.route53.zone_name.private
    comment   = var.env_name

    vpc {
        vpc_id = var.vpc_id
    }
    lifecycle {
        ignore_changes = [
            vpc
        ]
    }
}

resource "aws_route53_record" "public_web" {
    zone_id = aws_route53_zone.public.zone_id
    name    = var.route53.record_name.public.web
    type    = "A"
   
    alias {
        name                   = var.load_balancer.web.dns_name
        zone_id                = var.load_balancer.web.zone_id
        evaluate_target_health = false
  }
}

resource "aws_route53_record" "private_web" {
    count = length(var.ec2.private_ip.web)
    zone_id = aws_route53_zone.private.zone_id
    name    = "web${format("%02d", count.index + 1)}.${var.route53.zone_name.private}"
    type    = "A"
    ttl     = "300"
    records = ["${element(var.ec2.private_ip.web, count.index)}"]
}