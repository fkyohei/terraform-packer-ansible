#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Environment
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
variable "env" {
    default = "dev"
}
variable "env_name" {
    default = "Development"
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# AWS Settings
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
variable "region" {
    default = "ap-northeast-1"
}
variable "profile" {
    default = "【 your original aws profile name 】"
}
variable "availability_zone" {
    default = {
        zone_a = "ap-northeast-1a"
        zone_c = "ap-northeast-1c"
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# VPC
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
variable "vpc_cidr_block" {
    default = "192.1.0.0/16"
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Subnet
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
variable "subnet_cidr_block" {
    default = {
        public_a    = "192.1.10.0/24"
        public_c    = "192.1.11.0/24"
        private_a   = "192.1.20.0/24"
        private_c   = "192.1.21.0/24"
        db_a        = "192.1.30.0/24"
        db_c        = "192.1.31.0/24"
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Elastic IP
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
variable "elastic_ip" {
    default = {
        nat         = "【 get elastic ip for nat and paste allocation id here 】"
        step        = "【 get elastic ip for step instance and paste allocation id here 】"
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Security Group
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
variable "office_ip" {
    default = [
        "【 office ip address 】/32",
        "【 office ip address 2 】/32",
    ]
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# EC2
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
variable "ec2" {
    default = {
        step = {
            count           = 1
            ami_id          = "【 run packer command and paste ami id here 】"
            instance_type   = "t3.nano"
            key_name        = "【 get key and paste key name here 】"
            monitoring      = false
            private_ip      = ["【 set private ip you want to set for ec2 】"]
            tags            = ["Step"]
        }
        web = {
            count                   = 1
            ami_id                  = "【 run packer command and paste ami id here 】"
            instance_type           = "t3.micro"
            key_name                = "【 get key and paste key name here 】"
            monitoring              = false
            private_ip              = ["【 set private ip you want to set for ec2 】"]
            tags                    = ["Web"]
            iam_instance_profile    = "【 set iam instance profile 】"
        }
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ALB
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
variable "alb" {
    default = {
        ssl_policy      = "ELBSecurityPolicy-2016-08"
        certificate_arn = "【 set certificate arn from AWS Certificate Manager 】"
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ElastiCache
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
variable "redis" {
    default = {
        databases               = 99
        parameter_family        = "redis5.0"
        engine_version          = "5.0.6"
        node_type               = "cache.t3.micro"
        number_cache_clusters   = 2
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# RDS
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
variable "rds" {
    default = {
        parameter_family    = "mysql5.7"
        parameters          = {
            character_set_server    = "utf8mb4"
            slow_query_log          = 1
            long_query_time         = 1
            log_output              = "FILE"
            time_zone               = "Asia/Tokyo"
        }
        instance = {
            instance_class                  = "db.t3.micro"
            engine                          = "mysql"
            engine_version                  = "5.7.26"
            storage_type                    = "gp2"
            allocated_storage               = 20
            max_allocated_storage           = 0
            name                            = "【 set db name 】"
            username                        = "【 set db root user name 】"
            ca_cert_identifier              = "rds-ca-2019"
            enabled_cloudwatch_logs_exports = [
                "error",
                "slowquery"
            ]
        }
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Route53
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
variable "route53" {
    default = {
        zone_name = {
            public  = "【 set public zone name 】"
            private = "【 set private zone name 】"
        }
        record_name = {
            public = {
                web    = "【 set record name 】"
            }
        }
    }
}