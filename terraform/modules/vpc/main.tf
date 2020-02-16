#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Variables
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
variable "env_name" {}
variable "cidr_block" {
    default = {
        vpc                 = ""
        public_subnet_a     = ""
        public_subnet_c     = ""
        private_subnet_a    = ""
        private_subnet_c    = ""
        db_subnet_a         = ""
        db_subnet_c         = ""
    }
}
variable "availability_zone" {
    default = {
        zone_a = ""
        zone_c = ""
    }
}
variable "elastic_ip" {
    default = {
        nat = ""
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# VPC
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
resource "aws_vpc" "main" {
    cidr_block              = var.cidr_block.vpc
    instance_tenancy        = "default"
    enable_dns_support      = true
    enable_dns_hostnames    = true
    
    tags = {
        Name = var.env_name
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Subnet
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
resource "aws_subnet" "public_a" {
    vpc_id              = aws_vpc.main.id
    cidr_block          = var.cidr_block.public_subnet_a
    availability_zone   = var.availability_zone.zone_a

    tags = {
        Name = "Public Subnet -a | ${var.env_name}"
    }
}
resource "aws_subnet" "public_c" {
    vpc_id              = aws_vpc.main.id
    cidr_block          = var.cidr_block.public_subnet_c
    availability_zone   = var.availability_zone.zone_c

    tags = {
        Name = "Public Subnet -c | ${var.env_name}"
    }
}
resource "aws_subnet" "private_a" {
    vpc_id              = aws_vpc.main.id
    cidr_block          = var.cidr_block.private_subnet_a
    availability_zone   = var.availability_zone.zone_a

    tags = {
        Name = "Private Subnet -a | ${var.env_name}"
    }
}
resource "aws_subnet" "private_c" {
    vpc_id              = aws_vpc.main.id
    cidr_block          = var.cidr_block.private_subnet_c
    availability_zone   = var.availability_zone.zone_c

    tags = {
        Name = "Private Subnet -c | ${var.env_name}"
    }
}
resource "aws_subnet" "db_a" {
    vpc_id              = aws_vpc.main.id
    cidr_block          = var.cidr_block.db_subnet_a
    availability_zone   = var.availability_zone.zone_a

    tags = {
        Name = "DB Subnet -a | ${var.env_name}"
    }
}
resource "aws_subnet" "db_c" {
    vpc_id              = aws_vpc.main.id
    cidr_block          = var.cidr_block.db_subnet_c
    availability_zone   = var.availability_zone.zone_c

    tags = {
        Name = "DB Subnet -c | ${var.env_name}"
    }
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Internet Gateway
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "Internet Gateway | ${var.env_name}"
    }
}
resource "aws_nat_gateway" "main" {
    allocation_id = var.elastic_ip.nat
    subnet_id     = aws_subnet.public_a.id

    tags = {
        Name = "NAT Gateway | ${var.env_name}"
    }
}
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "Public Route Table | ${var.env_name}"
    }
}
resource "aws_route" "igw" {
    destination_cidr_block  = "0.0.0.0/0"
    route_table_id          = aws_route_table.public.id
    gateway_id              = aws_internet_gateway.main.id
}
resource "aws_route_table_association" "public_subnet_a" {
    subnet_id       = aws_subnet.public_a.id
    route_table_id  = aws_route_table.public.id
}
resource "aws_route_table_association" "public_subnet_c" {
    subnet_id       = aws_subnet.public_c.id
    route_table_id  = aws_route_table.public.id
}
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "Private Route Table | ${var.env_name}"
    }
}
resource "aws_route" "nat" {
    destination_cidr_block  = "0.0.0.0/0"
    route_table_id          = aws_route_table.private.id
    nat_gateway_id          = aws_nat_gateway.main.id
}
resource "aws_route_table_association" "private_subnet_a" {
    subnet_id       = aws_subnet.private_a.id
    route_table_id  = aws_route_table.private.id
}
resource "aws_route_table_association" "private_subnet_c" {
    subnet_id       = aws_subnet.private_c.id
    route_table_id  = aws_route_table.private.id
}