# Data sources to fetch existing VPC and subnets
data "aws_vpc" "eks_vpc" {
  id = var.vpc_id
}

# Gitlab runner's vpc
data "aws_vpc" "target_peering_vpc" {
  id = "vpc-0f4d614772ca8d3f0"
}

# Create additional private subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = data.aws_vpc.eks_vpc.id
  cidr_block              = var.environment == "production" ? "10.0.192.0/19" : "172.16.192.0/19"
  availability_zone       = "eu-west-3a"
  map_public_ip_on_launch = false
  tags = {
    Name = "rds_private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = data.aws_vpc.eks_vpc.id
  cidr_block              = var.environment == "production" ? "10.0.224.0/19" : "172.16.224.0/19"
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
  destination_cidr_block    = var.environment == "production" ? "10.0.0.0/16" : "172.16.0.0/16" # Replace with the other VPC's CIDR block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_gitlab_runner.id
}

# Create a route for the first VPC's CIDR block in the second VPC's route table
resource "aws_route" "vpc2_route" {
  route_table_id            = var.rtb_id
  destination_cidr_block    = "172.31.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_gitlab_runner.id
}