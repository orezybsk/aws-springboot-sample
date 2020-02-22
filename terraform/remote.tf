// Terraform s3 backend vs terraform_remote_state
// https://stackoverflow.com/questions/50820850/terraform-s3-backend-vs-terraform-remote-state
//
// asg-dns-handler
// https://registry.terraform.io/modules/meltwater/asg-dns-handler/aws/2.0.0
// https://github.com/meltwater/terraform-aws-asg-dns-handler
//
// Error in Terraform 0.12.0: This object has no argument, nested block, or exported attribute
// https://github.com/hashicorp/terraform/issues/21442
// ※terraform_remote_state で値を参照する時には ".outputs" が必要。
//
data "terraform_remote_state" "remote_sns_email" {
  backend = "s3"

  config = {
    bucket = "orezybsk-terraform-backend"
    key    = "aws-springboot-sample/terraform-sns-email.tfstate"
    region = "ap-northeast-1"
  }
}
data "aws_iam_policy_document" "assume_role_autoscaling" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["autoscaling.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "sns_email" {
  name               = "${var.project_name}-sns-email"
  assume_role_policy = data.aws_iam_policy_document.assume_role_autoscaling.json
}
data "aws_iam_policy_document" "sns_email" {
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
      "autoscaling:CompleteLifecycleAction"
    ]
    resources = [
      data.terraform_remote_state.remote_sns_email.outputs.sns_email_arn
    ]
  }
}
resource "aws_iam_role_policy" "sns_email" {
  name   = "${var.project_name}-sns-email"
  role   = aws_iam_role.sns_email.name
  policy = data.aws_iam_policy_document.sns_email.json
}
