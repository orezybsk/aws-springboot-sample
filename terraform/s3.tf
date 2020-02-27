///////////////////////////////////////////////////////////////////////////////
// S3
//
resource "aws_s3_bucket" "deploy_files" {
  bucket        = var.deploy_files_bucket_name
  force_destroy = true
}
data "aws_iam_policy_document" "deploy_files" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = [
      "${aws_s3_bucket.deploy_files.arn}",
      "${aws_s3_bucket.deploy_files.arn}/*"
    ]
  }
}
resource "aws_iam_policy" "deploy_files" {
  name   = "deploy_files_policy"
  policy = data.aws_iam_policy_document.deploy_files.json
}
locals {
  jar_path = format("%s/%s", var.build_libs_dir, var.jar_file)
}
resource "aws_s3_bucket_object" "upload_jar_file" {
  bucket = aws_s3_bucket.deploy_files.id
  key    = var.jar_file
  source = local.jar_path
  etag   = filemd5(local.jar_path)
}
