// Terraform で変数を使う
// https://qiita.com/ringo/items/3af1735cd833fb80da75
variable "project_name" {
  description = "プロジェクト名"
  type        = string
}
variable "key_name" {
  description = "aws_launch_configuration resource の key_name に指定するキーペア、EC2 インスタンスを生成する時に使用される"
  type        = string
}
variable "alb_access_logs_bucket_name" {
  description = "ALB のアクセスログを出力する S3 Bucket 名"
  type        = string
}
variable "db_master_username" {
  description = "aws_db_instance resource の username に指定する master ユーザ名"
  type        = string
}
variable "db_master_password_tmp" {
  description = "aws_db_instance resource の password に指定する master ユーザの一時的なパスワード"
  type        = string
}
variable "db_master_password" {
  description = "aws_db_instance resource の password に指定する master ユーザの正式なパスワード"
  type        = string
}
variable "db_port" {
  description = "aws_db_instance resource の port に指定する MySQL のポート番号"
  type        = number
  default     = 3306
}
variable "redis_port" {
  description = "aws_elasticache_replication_group resource の port に指定する Redis のポート番号"
  type        = number
  default     = 6379
}
variable "deploy_files_bucket_name" {
  description = "deploy するファイルをアップロードする S3 Bucket 名"
  type        = string
}
variable "server_port" {
  description = "Web アプリケーションのポート番号"
  type        = number
  default     = 8080
}

variable "db_name" {
  description = "RDS に作成する Web アプリケーション用 DB名"
  type        = string
}
variable "db_username" {
  description = "RDS に作成する Web アプリケーション用 DB で使用するユーザ名"
  type        = string
}
variable "db_password" {
  description = "RDS に作成する Web アプリケーション用 DB で使用するユーザのパスワード"
  type        = string
}

variable "create_rds" {
  description = "RDS(MySQL) を作成するか否かを指定するフラグ"
  type        = bool
  default     = true
}
variable "create_elasticache" {
  description = "ElastiCache(Redis) を作成するか否かを指定するフラグ"
  type        = bool
  default     = true
}
