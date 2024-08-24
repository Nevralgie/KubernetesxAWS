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

output "Environment"
  description = "Working Env"
  value       = var.environment