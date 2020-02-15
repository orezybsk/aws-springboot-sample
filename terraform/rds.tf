///////////////////////////////////////////////////////////////////////////////
// RDS (MySQL)
//
// AWSのEC2で行うAmazon Linux2（MySQL5.7）環境構築
// https://qiita.com/2no553/items/952dbb8df9a228195189
//
resource "aws_security_group" "sg_db" {
  name   = "${var.project_name}-sg-db"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = var.db_port
    protocol        = "tcp"
    to_port         = var.db_port
    security_groups = [aws_security_group.sg_asg.arn]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_db_parameter_group" "this" {
  name   = "${var.project_name}-db-parameter-group"
  family = "mysql5.7"

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_filesystem"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }
}
// ※翌日にならないと destroy が成功しなくなるので、aws_db_option_group はコメントアウトする。必要に応じて解除すること。
//// MySQL DB インスタンスのオプション
//// https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/Appendix.MySQL.Options.html
//resource "aws_db_option_group" "this" {
//  name                 = "${var.project_name}-db-option-group"
//  engine_name          = "mysql"
//  major_engine_version = "5.7"
//
//  // MariaDB 監査プラグインのサポート
//  // https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/Appendix.MySQL.Options.AuditPlugin.html
//  option {
//    option_name = "MARIADB_AUDIT_PLUGIN"
//  }
//}
resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.private_0.id, aws_subnet.private_1.id]
}
resource "aws_db_instance" "this" {
  identifier = "${var.project_name}-db"
  engine     = "mysql"
  // Amazon RDS での MySQL
  // https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/CHAP_MySQL.html 参照
  engine_version = "5.7.26"
  // DB インスタンスクラスの選択
  // https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
  instance_class = "db.t3.small"
  // instance_class = "db.t3.xlarge"
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.this.arn
  username              = var.db_username
  password              = var.db_password_tmp
  multi_az              = true
  publicly_accessible   = false
  backup_window         = "17:10-17:40"
  // 通常は 30 にする
  backup_retention_period = 1
  // DB インスタンスのメンテナンス
  // https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.Maintenance.html
  maintenance_window         = "Mon:18:10-Mon:18:40"
  auto_minor_version_upgrade = false
  // 通常は true にする（DBインスタンスが削除できなくなる）
  deletion_protection       = false
  skip_final_snapshot       = true
  final_snapshot_identifier = "${var.project_name}-db-final-snapshot"
  port                      = var.db_port
  apply_immediately         = false
  vpc_security_group_ids    = [aws_security_group.sg_db.id]
  parameter_group_name      = aws_db_parameter_group.this.name
  // ※翌日にならないと destroy が成功しなくなるので、aws_db_option_group はコメントアウトする。必要に応じて解除すること。
  // option_group_name = aws_db_option_group.this.name
  db_subnet_group_name = aws_db_subnet_group.this.name

  lifecycle {
    ignore_changes = [password]
  }

  // 上で設定した password は tfstate に残るので、リソース作成後に aws コマンドで変更する
  // aws-vault exec $AWS_PROFILE -- bash -c "aws rds modify-db-instance --apply-immediately --db-instance-identifier <aws_db_instance.this.identifier> --master-user-password '<var.db_password>'"
}
output "modify_db_password_command" {
  value = format("aws-vault exec $AWS_PROFILE -- bash -c \"aws rds modify-db-instance --apply-immediately --db-instance-identifier %s --master-user-password '%s'\"",
    aws_db_instance.this.identifier,
    var.db_password
  )
}

// インストール後 Public Subnet 内の EC2 Instance で以下のコマンドを実行して動作確認する
// sudo yum localinstall https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm -y
// sudo yum-config-manager --disable mysql80-community
// sudo yum-config-manager --enable mysql57-community
// sudo yum install mysql-community-client -y
// mysql -h <RDSのEndpoint> -u <username> -p
// mysql> show global variables like 'character%';
