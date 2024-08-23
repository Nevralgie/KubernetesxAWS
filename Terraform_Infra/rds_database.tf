resource "aws_db_instance" "rds_mysql" {
  allocated_storage    = 20
  db_name              = "db_app"
  identifier           = "devopsdb-app"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  multi_az             = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot  = false
  final_snapshot_identifier = "deploy-state"
}
