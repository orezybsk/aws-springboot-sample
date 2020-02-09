terraform {
  required_version = "0.12.20"
}

provider "aws" {
  region = "ap-northeast-1"
}

///////////////////////////////////////////////////////////////////////////////
// IAM User (terraform_user)
// ここで作成した後に AWS Management Console に別の IAM User でログインして、
// ACCESS_KEY_ID, SECRET_ACCESS_KEY を作成し、MFA を設定する
//
resource "aws_iam_user" "terraform_user" {
  name = var.terraform_user_name
  // MFAデバイスを登録していると削除できないので forace_destroy を true にしている
  force_destroy = true
}
resource "aws_iam_user_policy_attachment" "terraform_user" {
  user       = aws_iam_user.terraform_user.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

///////////////////////////////////////////////////////////////////////////////
// IAM Role (terraform_exec_role)
//
data "aws_iam_policy_document" "terraform_exec_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.terraform_user.arn]
    }
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = [true]
    }
  }
}
resource "aws_iam_role" "terraform_exec_role" {
  name               = var.terraform_exec_role_name
  assume_role_policy = data.aws_iam_policy_document.terraform_exec_role.json
}
resource "aws_iam_role_policy_attachment" "terraform_exec_role" {
  role       = aws_iam_role.terraform_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

///////////////////////////////////////////////////////////////////////////////
// S3
//
resource "aws_s3_bucket" "terraform_tfstate" {
  bucket = var.backend_bucket_name

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    expiration {
      days = 7
    }
  }
}

///////////////////////////////////////////////////////////////////////////////
// DynamoDB
//
// S3
// https://www.terraform.io/docs/backends/types/s3.html
// docs improvement - add s3 dynamodb lock table terraform definition
// https://github.com/hashicorp/terraform/issues/12877
resource "aws_dynamodb_table" "terraform_tfstate_lock" {
  name           = var.backend_dynamodb_table_name
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
