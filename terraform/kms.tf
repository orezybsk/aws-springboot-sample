///////////////////////////////////////////////////////////////////////////////
// KMS
//
resource "aws_kms_key" "this" {
  description             = "${var.project_name}-kms-key"
  enable_key_rotation     = true
  is_enabled              = true
  deletion_window_in_days = 30
}
resource "aws_kms_alias" "this" {
  name          = "alias/${var.project_name}-kms-key"
  target_key_id = aws_kms_key.this.id
}
