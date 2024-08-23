# Security group for the RDS instance
resource "aws_security_group" "rds_sg" {
  description = "SG allowing 3306 for MySQL from nodes and runner"
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

