// Terraform で変数を使う
// https://qiita.com/ringo/items/3af1735cd833fb80da75
variable "project_name" {}
variable "key_name" {}
variable "alb_access_logs_bucket_name" {}
variable "db_username" {}
variable "db_password_tmp" {}
variable "db_password" {}
variable "db_port" {}
variable "redis_port" {}

variable "create_rds" {}
variable "create_elasticache" {}
