variable "vpc_id" {
  description = "EKS VPC"
  type = string
}

variable "rtb_id" {
  description = "EKS VPC ROUTE TABLE"
  type = string
}

variable "db_username" {
  description = "Database username"
  type = string
}

variable "db_password" {
  description = "Database password"
  type = string
}