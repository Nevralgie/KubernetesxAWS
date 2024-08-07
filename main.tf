terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.47.0"
    }
  }



  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/57372801/terraform/state/eks_state"
    lock_address   = "https://gitlab.com/api/v4/projects/57372801/terraform/state/eks_state/lock"
    unlock_address = "https://gitlab.com/api/v4/projects/57372801/terraform/state/eks_state/lock"
    username       = "Nevii"
    password       = "glpat-yS4rHMDjCvvyUF4hZ4G8"
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
    }
  
}
provider "aws" {
  region = "eu-west-3"
}


# Data sources to fetch existing VPC and subnets
data "aws_vpc" "eks_vpc" {
  id = var.vpc_id
}

# Create additional private subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = data.aws_vpc.eks_vpc.id
  cidr_block              = "192.168.192.0/19"
  availability_zone       = "eu-west-3a"
  map_public_ip_on_launch = false
  tags = {
    Name = "rds_private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = data.aws_vpc.eks_vpc.id
  cidr_block              = "192.168.224.0/19"
  availability_zone       = "eu-west-3b"
  map_public_ip_on_launch = false
  tags = {
    Name = "rds_private-subnet-2"
  }
}

# Create an RDS subnet group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "eks_rds_db_group"
  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]
  tags = {
    Name = "Eks RDS Subnet Group"
  }
}

resource "aws_db_instance" "rds_mysql" {
  allocated_storage    = 20
  db_name              = "db_app"
  identifier           = "devopsdb-app"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "vAdmintestv"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  multi_az             = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot  = false
  final_snapshot_identifier = true
}

# Security group for the RDS instance
resource "aws_security_group" "rds_sg" {
  vpc_id = data.aws_vpc.eks_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql" {
  security_group_id = aws_security_group.rds_sg.id
  cidr_ipv4         = "192.168.0.0/16"
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql_gitlabrunner" {
  security_group_id = aws_security_group.rds_sg.id
  cidr_ipv4         = "172.31.32.99/32"
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_out" {
  security_group_id = aws_security_group.rds_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


output "rds_address" {
  value = aws_db_instance.rds_mysql.address
}

output "database_username" {
  description = "The username of the database"
  value       = aws_db_instance.rds_mysql.username
}

output "database_password" {
  description = "The password of the database"
  value       = aws_db_instance.rds_mysql.password
  sensitive = true
}

output "database_name" {
  description = "The name of the database"
  value       = aws_db_instance.rds_mysql.db_name
}

data "aws_vpc" "target_peering_vpc" {
  id = "vpc-0f4d614772ca8d3f0"
}

resource "aws_vpc_peering_connection" "vpc_gitlab_runner" {
  peer_vpc_id   = var.vpc_id
  vpc_id        = data.aws_vpc.target_peering_vpc.id

  tags = {
    Side = "Requester"
  }
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_gitlab_runner.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

# Create a route for the second VPC's CIDR block in the first VPC's route table
resource "aws_route" "main_vpc_route_to_k8s" {
  route_table_id            = "rtb-0cb9914b16f6618ed"
  destination_cidr_block    = "192.168.0.0/16" # Replace with the other VPC's CIDR block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_gitlab_runner.id
}

# Create a route for the first VPC's CIDR block in the second VPC's route table
resource "aws_route" "vpc2_route" {
  route_table_id            = var.rtb_id
  destination_cidr_block    = "172.31.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_gitlab_runner.id
}