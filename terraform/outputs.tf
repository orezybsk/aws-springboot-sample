output "rds_endpoint" {
  value = element(split(":", aws_db_instance.this.endpoint), 0)
}
output "modify_db_password_command" {
  value = format("aws-vault exec $AWS_PROFILE -- bash -c \"aws rds modify-db-instance --apply-immediately --db-instance-identifier %s --master-user-password '%s'\"",
  aws_db_instance.this.identifier, var.db_master_password)
}
