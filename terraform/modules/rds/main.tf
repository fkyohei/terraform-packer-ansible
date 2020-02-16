#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Variables
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
variable "env" {}
variable "env_name" {}
variable "subnet_ids" {
    default = []
}
variable "security_group_ids" {
    default = []
}
variable "rds" {
    default = {
        parameter_family    = ""
        parameters          = {
            character_set_server    = ""
            slow_query_log          = ""
            long_query_time         = ""
            log_output              = ""
            time_zone               = ""
        }
        instance = {
            instance_class                  = ""
            engine                          = ""
            engine_version                  = ""
            storage_type                    = ""
            allocated_storage               = ""
            max_allocated_storage           = ""
            name                            = ""
            username                        = ""
            ca_cert_identifier              = ""
            enabled_cloudwatch_logs_exports = []
        }
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Datas
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
data "aws_ssm_parameter" "password" {
    name = "${var.env}-rds-db-root-password"
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# RDS
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
resource "aws_db_subnet_group" "main" {
    name        = "rds-subnet-${lower(var.env_name)}"
    subnet_ids  = var.subnet_ids
}

resource "aws_db_parameter_group" "main" {
    count = var.env == "dev" ? "1" : "0"
    name = "rds-parameter-group-${lower(var.env_name)}"
    family = var.rds.parameter_family

    parameter {
        name    = "character_set_server"
        value   = var.rds.parameters.character_set_server
    }

    parameter {
        name    = "slow_query_log"
        value   = var.rds.parameters.slow_query_log
    }

    parameter {
        name    = "long_query_time"
        value   = var.rds.parameters.long_query_time
    }

    parameter {
        name    = "log_output"
        value   = var.rds.parameters.log_output
    }

    parameter {
        name    = "time_zone"
        value   = var.rds.parameters.time_zone
    }
}

resource "aws_db_instance" "main" {
    count                           = var.env == "dev" ? "1" : "0"
    identifier                      = "db-${lower(var.env_name)}"
    final_snapshot_identifier       = "db-${lower(var.env_name)}-${formatdate("YYYY-MM-DD-hh-mm", timestamp())}"
    instance_class                  = var.rds.instance.instance_class
    engine                          = var.rds.instance.engine
    engine_version                  = var.rds.instance.engine_version
    parameter_group_name            = aws_db_parameter_group.main.0.name
    db_subnet_group_name            = aws_db_subnet_group.main.name
    vpc_security_group_ids          = var.security_group_ids
    storage_type                    = var.rds.instance.storage_type
    allocated_storage               = var.rds.instance.allocated_storage
    max_allocated_storage           = var.rds.instance.max_allocated_storage
    name                            = var.rds.instance.name
    username                        = var.rds.instance.username
    password                        = data.aws_ssm_parameter.password.value
    ca_cert_identifier              = var.rds.instance.ca_cert_identifier
    enabled_cloudwatch_logs_exports = var.rds.instance.enabled_cloudwatch_logs_exports
}