// RDS(MySQL) に terraform から設定した password は tfstate に残るので、リソース作成後に aws コマンドで変更する
output "modify_db_password_command" {
  value = format("aws-vault exec $AWS_PROFILE -- bash -c \"aws rds modify-db-instance --apply-immediately --db-instance-identifier %s --master-user-password '%s'\"",
    aws_db_instance.this.identifier,
    var.db_password
  )
}
