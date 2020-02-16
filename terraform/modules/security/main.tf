#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Variables
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
variable "env" {}
variable "env_name" {}
variable "vpc_id" {}
variable "office_ip" {
    default = []
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Security Group
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
resource "aws_security_group" "step_servers" {
    name        = "Step"
    vpc_id      = var.vpc_id
    description = "For Step Servers"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Step Servers | ${var.env_name}"
    }
}
resource "aws_security_group_rule" "step_server_22_from_office" {
    security_group_id   = aws_security_group.step_servers.id
    type                = "ingress"
    from_port           = "22"
    to_port             = "22"
    protocol            = "tcp"
    cidr_blocks         = var.office_ip
    description         = "allow Office Internal IP"
}
resource "aws_security_group" "from_step_servers" {
    name        = "From Step"
    vpc_id      = var.vpc_id
    description = "For Server Access From Step Servers"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "From Step | ${var.env_name}"
    }
}
resource "aws_security_group_rule" "server_22_from_step" {
    security_group_id           = aws_security_group.from_step_servers.id
    type                        = "ingress"
    from_port                   = "22"
    to_port                     = "22"
    protocol                    = "tcp"
    source_security_group_id    = aws_security_group.step_servers.id
    description                 = "allow 22 from Step IP"
}
resource "aws_security_group_rule" "server_873_from_step" {
    count                       = var.env == "dev" ? "1" : "0"
    security_group_id           = aws_security_group.from_step_servers.id
    type                        = "ingress"
    from_port                   = "873"
    to_port                     = "873"
    protocol                    = "tcp"
    source_security_group_id    = aws_security_group.step_servers.id
    description                 = "allow 873 from Step IP"
}
resource "aws_security_group" "web_alb" {
    name        = "Web ALB"
    vpc_id      = var.vpc_id
    description = "For Web ALB"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Web ALB | ${var.env_name}"
    }
}
resource "aws_security_group_rule" "web_alb_80_from_office" {
    security_group_id   = aws_security_group.web_alb.id
    type                = "ingress"
    from_port           = "80"
    to_port             = "80"
    protocol            = "tcp"
    cidr_blocks         = var.office_ip
    description         = "allow Office Internal IP"
}
resource "aws_security_group_rule" "web_alb_443_from_office" {
    security_group_id   = aws_security_group.web_alb.id
    type                = "ingress"
    from_port           = "443"
    to_port             = "443"
    protocol            = "tcp"
    cidr_blocks         = var.office_ip
    description         = "allow Office Internal IP"
}
resource "aws_security_group" "web_servers" {
    name        = "Web"
    vpc_id      = var.vpc_id
    description = "For Web Servers"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Web Servers | ${var.env_name}"
    }
}
resource "aws_security_group_rule" "web_server_80_from_web_alb" {
    security_group_id           = aws_security_group.web_servers.id
    type                        = "ingress"
    from_port                   = "80"
    to_port                     = "80"
    protocol                    = "tcp"
    source_security_group_id    = aws_security_group.web_alb.id
    description                 = "allow HTTP"
}
resource "aws_security_group_rule" "web_server_443_from_web_alb" {
    security_group_id           = aws_security_group.web_servers.id
    type                        = "ingress"
    from_port                   = "443"
    to_port                     = "443"
    protocol                    = "tcp"
    source_security_group_id    = aws_security_group.web_alb.id
    description                 = "allow HTTPS"
}

resource "aws_security_group" "rds_db" {
    name        = "RDS DB"
    vpc_id      = var.vpc_id
    description = "For RDS DB"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "RDS DB | ${var.env_name}"
    }
}
resource "aws_security_group_rule" "rds_db_3306_from_step_server" {
    security_group_id           = aws_security_group.rds_db.id
    type                        = "ingress"
    from_port                   = "3306"
    to_port                     = "3306"
    protocol                    = "tcp"
    source_security_group_id    = aws_security_group.step_servers.id
    description                 = "allow 3306 from Step Servers"
}
resource "aws_security_group_rule" "rds_db_3306_from_web_server" {
    security_group_id           = aws_security_group.rds_db.id
    type                        = "ingress"
    from_port                   = "3306"
    to_port                     = "3306"
    protocol                    = "tcp"
    source_security_group_id    = aws_security_group.web_servers.id
    description                 = "allow 3306 from Web Servers"
}
resource "aws_security_group" "redis" {
    name        = "Redis"
    vpc_id      = var.vpc_id
    description = "For Redis"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Redis | ${var.env_name}"
    }
}
resource "aws_security_group_rule" "redis_6379_from_web_server" {
    security_group_id           = aws_security_group.redis.id
    type                        = "ingress"
    from_port                   = "6379"
    to_port                     = "6379"
    protocol                    = "tcp"
    source_security_group_id    = aws_security_group.web_servers.id
    description                 = "allow 6379 from Web Servers"
}