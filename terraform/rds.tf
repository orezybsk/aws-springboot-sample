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
  username              = var.db_master_username
  password              = var.db_master_password_tmp
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

  provisioner "local-exec" {
    command = format("echo 'modify_db_password_command: aws-vault exec $AWS_PROFILE -- bash -c \"aws rds modify-db-instance --apply-immediately --db-instance-identifier %s --master-user-password '%s'\"'",
      aws_db_instance.this.identifier,
      var.db_master_password
    )
  }
}
// Resource: aws_db_event_subscription
// https://www.terraform.io/docs/providers/aws/r/db_event_subscription.html
resource "aws_db_event_subscription" "this" {
  name      = "${var.project_name}-db-event"
  sns_topic = data.terraform_remote_state.remote_sns_email.outputs.sns_email_arn

  source_type = "db-instance"
  source_ids  = [aws_db_instance.this.id]

  // Using Amazon RDS Event Notification
  // https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Events.html
  event_categories = [
    "availability",
    "deletion",
    "failover",
    "failure",
    "low storage",
    "maintenance",
    "read replica",
    "recovery",
    "restoration",
  ]
}

///////////////////////////////////////////////////////////////////////////////
// Lambda (rds_creattion)
// RDSの生成完了直後に呼び出される
//
data "aws_iam_policy_document" "assume_role_lambda" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "rds_create_db" {
  name               = "${var.project_name}-rdsCreateDb"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
}
resource "aws_cloudwatch_log_group" "rds_create_db_log" {
  name              = "/aws/lambda/rdsCreateDb"
  retention_in_days = 3
}
data "aws_iam_policy_document" "rds_create_db" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      # 下の３つは AWSLambdaVPCAccessExecutionRole Policy より抜粋
      # VPC内で Lambda を実行する時に必要
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "rds_create_db" {
  name   = "${var.project_name}-rdsCreateDb"
  role   = aws_iam_role.rds_create_db.id
  policy = data.aws_iam_policy_document.rds_create_db.json
}
data "archive_file" "rds_create_db_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda/rdsCreateDb.zip"
  source_dir  = "${path.module}/lambda/rdsCreateDb/"
}
resource "aws_lambda_function" "rds_create_db" {
  depends_on = [aws_cloudwatch_log_group.rds_create_db_log, aws_iam_role_policy.rds_create_db, aws_db_instance.this]

  function_name    = "${var.project_name}-rdsCreateDb"
  handler          = "main.lambda_handler"
  filename         = data.archive_file.rds_create_db_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.rds_create_db_zip.output_path)

  role    = aws_iam_role.rds_create_db.arn
  runtime = "python3.8"
  timeout = 15

  vpc_config {
    security_group_ids = [aws_security_group.sg_asg.id]
    subnet_ids         = [aws_subnet.private_0.id, aws_subnet.private_1.id]
  }

  // https://docs.aws.amazon.com/cli/latest/reference/lambda/invoke.html
  // lambda-exec
  // https://registry.terraform.io/modules/connect-group/lambda-exec/aws/1.0.2
  provisioner "local-exec" {
    command = format("aws lambda invoke --function-name %s --payload '%s' response.json",
      aws_lambda_function.rds_create_db.function_name,
      jsonencode(merge(map(
        // RDS exported attribute 'endpoint' should not include port number
        // https://github.com/hashicorp/terraform/issues/4996
        "RDS_ENDPOINT", element(split(":", aws_db_instance.this.endpoint), 0),
        "DB_MASTER_USERNAME", var.db_master_username,
        "DB_MASTER_PASSWORD", var.db_master_password_tmp,
        "DB_NAME", var.db_name,
        "DB_USERNAME", var.db_username,
        "DB_PASSWORD", var.db_password
      )))
    )
    // Git for Windows の bash.exe を使用して aws lambda invoke コマンドを実行する
    interpreter = ["bash.exe", "-c"]
  }
}

// インストール後 Public Subnet 内の EC2 Instance で以下のコマンドを実行して動作確認する
// sudo yum localinstall https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm -y
// sudo yum-config-manager --disable mysql80-community
// sudo yum-config-manager --enable mysql57-community
// sudo yum install mysql-community-client -y
// mysql -h <RDSのEndpoint> -u <username> -p
// mysql> show global variables like 'character%';

// Running Setup SQL scripts on an RDS instance within a VPC, via Terraform
// https://gist.github.com/pat/7b61376981b40cfdbb1166734b8d184f
