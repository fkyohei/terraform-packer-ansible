#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# S3 Settings For Terraform 
# 
# 注意）backend部分のみ、変数が使用できない
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
terraform {
    required_version = "~> 0.12"
    backend "s3" {
        bucket  = "【 set S3 bucker name 】"
        region  = "ap-northeast-1"
        profile = "【 your original aws profile name 】"
        key     = "terraform.tfstate.aws"
        encrypt = true
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# AWS Settings
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
provider "aws" {
    region  = var.region
    profile = var.profile
    version = "~> 2.42"
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# VPC
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
module "vpc" {
    source = "../modules/vpc"

    env_name            = var.env_name
    availability_zone   = var.availability_zone
    elastic_ip          = var.elastic_ip
    cidr_block          = {
        vpc                 = var.vpc_cidr_block
        public_subnet_a     = var.subnet_cidr_block.public_a
        public_subnet_c     = var.subnet_cidr_block.public_c
        private_subnet_a    = var.subnet_cidr_block.private_a
        private_subnet_c    = var.subnet_cidr_block.private_c
        db_subnet_a         = var.subnet_cidr_block.db_a
        db_subnet_c         = var.subnet_cidr_block.db_c
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Security
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
module "security" {
    source = "../modules/security"

    env      = var.env
    env_name = var.env_name
    vpc_id   = module.vpc.vpc_id
    office_ip   = var.office_ip
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# EC2
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
module "ec2_web" {
    source = "../modules/ec2/web"

    env                 = var.env
    env_name            = var.env_name
    subnet_ids          = [
        module.vpc.subnet_private_a_id,
        module.vpc.subnet_private_c_id
    ]
    security_group_ids = {
        web = [
            module.security.security_group_from_step_servers_id,
            module.security.security_group_web_servers_id
        ]
    }
    ec2 = {
        web = var.ec2.web
    }
}
module "ec2_step" {
    source = "../modules/ec2/step"

    env                 = var.env
    env_name            = var.env_name
    elastic_ip          = var.elastic_ip
    subnet_ids          = [
        module.vpc.subnet_public_a_id,
        module.vpc.subnet_public_c_id
    ]
    security_group_ids = {
        step = [
            module.security.security_group_step_servers_id
        ]
    }
    ec2 = {
        step        = var.ec2.step
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Load Balancer
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
module "load_balancer" {
    source = "../modules/load_balancer"

    env_name    = var.env_name
    vpc_id      = module.vpc.vpc_id
    alb         = var.alb
    subnet_ids  = [
        module.vpc.subnet_public_a_id,
        module.vpc.subnet_public_c_id
    ]
    security_group_ids = {
        web_alb = module.security.security_group_web_alb_id
    }
    ec2_instance_ids = {
        web         = module.ec2_web.ec2_instance_web_ids
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ElastiCache
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
module "elasticache" {
    source = "../modules/elasticache"

    env_name    = var.env_name
    redis       = var.redis
    subnet_ids  = [
        module.vpc.subnet_db_a_id,
        module.vpc.subnet_db_c_id
    ]
    security_group_ids = [
        module.security.security_group_redis_id
    ]
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# RDS
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
module "rds" {
    source = "../modules/rds"

    env         = var.env
    env_name    = var.env_name
    rds         = var.rds
    subnet_ids  = [
        module.vpc.subnet_db_a_id,
        module.vpc.subnet_db_c_id
    ]
    security_group_ids = [
        module.security.security_group_rds_db_id
    ]
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Route53
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
module "route53" {
    source = "../modules/route53"

    env_name    = var.env_name
    vpc_id      = module.vpc.vpc_id
    route53     = var.route53
    ec2         = {
        private_ip = {
            web         = module.ec2_web.ec2_instance_web_private_ips
        }
    }
    load_balancer = {
        web = {
            dns_name    = module.load_balancer.load_balancer_web_alb_dns_name
            zone_id     = module.load_balancer.load_balancer_web_alb_zone_id
        }
    }
}