#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Variables
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
variable "env_name" {}
variable "subnet_ids" {
    default = []
}
variable "security_group_ids" {
    default = []
}
variable "redis" {
    default = {
        databases               = ""
        parameter_family        = ""
        engine_version          = ""
        node_type               = ""
        number_cache_clusters   = ""
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ElastiCache
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
resource "aws_elasticache_subnet_group" "main" {
    name        = "Redis-Subnet-${var.env_name}"
    subnet_ids  = var.subnet_ids
}

resource "aws_elasticache_parameter_group" "main" {
    name   = "Redis-Parameter-Group-${var.env_name}"
    family = var.redis.parameter_family

    parameter {
        name  = "databases"
        value = var.redis.databases
    }
}

resource "aws_elasticache_replication_group" "main" {
    engine                  = "redis"
    engine_version          = var.redis.engine_version
    replication_group_id    = "Redis-${var.env_name}"
    node_type               = var.redis.node_type
    number_cache_clusters   = var.redis.number_cache_clusters
    port                    = 6379
    parameter_group_name    = aws_elasticache_parameter_group.main.name
    subnet_group_name       = aws_elasticache_subnet_group.main.name
    security_group_ids      = var.security_group_ids
    replication_group_description = "Redis-${var.env_name}"
}