terraform {
  required_version = "0.12.20"

  // https://www.terraform.io/docs/backends/types/s3.html 参照。
  // backend では var.～ は使用できない
  backend "s3" {
    bucket = "orezybsk-terraform-backend"
    key    = "aws-springboot-sample/terraform-sns-email.tfstate"
    region = "ap-northeast-1"

    dynamodb_table = "orezybsk-terraform-backend-lock"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

///////////////////////////////////////////////////////////////////////////////
// SNS
//
// deanwilson / tf_sns_email
// https://github.com/deanwilson/tf_sns_email
// AWS SNS topic Subscription with email protocol using Terraform
// https://medium.com/@raghuram.arumalla153/aws-sns-topic-subscription-with-email-protocol-using-terraform-ed05f4f19b73
data "template_file" "cf_stack_sns_email" {
  template = file("${path.module}/cf-stack-sns-email.json.tpl")
  vars = {
    display_name  = "${var.project_name}-cf-stack-sns-email"
    email_address = var.email
  }
}
resource "aws_cloudformation_stack" "cf_stack_sns_email" {
  name          = "${var.project_name}-cf-stack-sns-email"
  template_body = data.template_file.cf_stack_sns_email.rendered
}
output "sns_email_arn" {
  value = aws_cloudformation_stack.cf_stack_sns_email.outputs.ARN
}
