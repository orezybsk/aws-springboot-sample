// Linux AMI の検索
// https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/finding-an-ami.html
data "aws_ami" "recent_amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.????????.?-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

///////////////////////////////////////////////////////////////////////////////
// IAM Instance Profile (for ssm)
//
data "aws_iam_policy_document" "ec2_for_ssm" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "ec2_for_ssm" {
  name               = "${var.project_name}-ec2-for-ssm"
  assume_role_policy = data.aws_iam_policy_document.ec2_for_ssm.json
}
data "aws_iam_policy" "ec2_for_ssm" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "ec2_for_ssm" {
  policy_arn = data.aws_iam_policy.ec2_for_ssm.arn
  role       = aws_iam_role.ec2_for_ssm.name
}
data "aws_iam_policy_document" "ssm_get_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:Get*",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "ssm_get_policy" {
  name   = "${var.project_name}-ssm-get-policy"
  role   = aws_iam_role.ec2_for_ssm.id
  policy = data.aws_iam_policy_document.ssm_get_policy.json
}
resource "aws_iam_role_policy_attachment" "deploy_files" {
  policy_arn = aws_iam_policy.deploy_files.arn
  role       = aws_iam_role.ec2_for_ssm.name
}
resource "aws_iam_instance_profile" "ec2_for_ssm" {
  name = "${var.project_name}-ec2-for-ssm"
  role = aws_iam_role.ec2_for_ssm.name
}

///////////////////////////////////////////////////////////////////////////////
// S3 (for ALB access logs)
//
resource "aws_s3_bucket" "alb-access-logs" {
  bucket = var.alb_access_logs_bucket_name
  // alb を作成するとログファイルが作成されて destroy 出来なくなるの force_destroy を true にしておく
  force_destroy = true

  lifecycle_rule {
    enabled = true
    expiration {
      days = 1
    }
  }
}
data "aws_iam_policy_document" "alb_access_logs" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.alb-access-logs.id}/*"]

    // 582318560864 は
    // ap-northeast-1 の Elastic Load Balancing アカウント ID
    // 以下のページ参照
    // Classic Load Balancer のアクセスログの有効化
    // https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/classic/enable-access-logs.html
    principals {
      type        = "AWS"
      identifiers = ["582318560864"]
    }
  }
}
resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb-access-logs.id
  policy = data.aws_iam_policy_document.alb_access_logs.json
}

///////////////////////////////////////////////////////////////////////////////
// ALB
//
resource "aws_security_group" "sg_alb" {
  name   = "${var.project_name}-sg-alb"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_alb" "alb" {
  name                       = "${var.project_name}-alb"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = false

  subnets = [
    aws_subnet.public_0.id,
    aws_subnet.public_1.id
  ]

  access_logs {
    bucket  = aws_s3_bucket.alb-access-logs.id
    enabled = true
  }

  security_groups = [
    aws_security_group.sg_alb.id
  ]
}
resource "aws_alb_listener" "alb_http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = 404
    }
  }
}
resource "aws_alb_target_group" "alb_http" {
  name     = "${var.project_name}-alb-http"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path     = "/"
    protocol = "HTTP"
    port     = var.server_port
    matcher  = 200
    // 300秒（5分）は長い気がする。120秒（2分）くらいが妥当？
    interval            = 300
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
resource "aws_lb_listener_rule" "alb_http" {
  listener_arn = aws_alb_listener.alb_http.arn
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_http.arn
  }
  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

///////////////////////////////////////////////////////////////////////////////
// Auto Scaling Group
//
resource "aws_security_group" "sg_asg" {
  name   = "${var.project_name}-sg-asg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = var.server_port
    protocol        = "tcp"
    to_port         = var.server_port
    security_groups = [aws_security_group.sg_alb.arn]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_launch_configuration" "asg" {
  name_prefix                 = "${var.project_name}-asg-launch-configuration"
  image_id                    = data.aws_ami.recent_amazon_linux_2.image_id
  instance_type               = "t3.micro"
  security_groups             = [aws_security_group.sg_asg.id]
  associate_public_ip_address = false
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_for_ssm.name

  // 空き容量は以下のコマンドで分かる
  // df -hT /dev/xvda1
  // Amazon EBS ボリュームに関する情報を表示する
  // https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/ebs-describing-volumes.html
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true
  }

  //user_data = <<EOF
  //  #!/bin/bash
  //  amazon-linux-extras install nginx1
  //  systemctl start nginx
  //  systemctl enable nginx
  //EOF

  // Amazon Linux 2 における Amazon Corretto 11 のインストール手順
  // https://docs.aws.amazon.com/ja_jp/corretto/latest/corretto-11-ug/amazon-linux-install.html
  // パラメータストアからEC2に環境変数を設定する
  // https://qiita.com/th_/items/8ffb28dd6d27779a6c9d
  //
  // user_data の実行結果は /var/log/cloud-init-output.log に出力される
  //
  user_data = <<EOF
    #!/bin/bash
    yum install jq -y
    SSM_PARAMETERS=$(aws --region ap-northeast-1 ssm get-parameters-by-path --path "/springbootSample/product" --with-decryption)
    echo $SSM_PARAMETERS
    for param in $(echo $SSM_PARAMETERS | jq -r '.Parameters[] | .Name + "=" + .Value | gsub("/springbootSample/product/"; "")'); do
        echo $param
        export $param
    done

    yum install java-11-amazon-corretto -y
    cd /opt
    mkdir sample-webapp
    cd sample-webapp
    aws s3 cp s3://${var.deploy_files_bucket_name}/sample-webapp-2.2.4-RELEASE.jar .
    nohup java -Djava.net.preferIPv4Stack=true -Dspring.profiles.active=product -jar sample-webapp-2.2.4-RELEASE.jar
  EOF

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "asg" {
  depends_on = [
    aws_ssm_parameter.SPRING_DATASOURCE_HIKARI_JDBC_URL,
    aws_ssm_parameter.SPRING_REDIS_CLUSTER_NODES,
    aws_s3_bucket_object.upload_jar_file
  ]

  name                 = "${var.project_name}-asg"
  launch_configuration = aws_launch_configuration.asg.name
  vpc_zone_identifier  = [aws_subnet.public_0.id, aws_subnet.public_1.id]

  target_group_arns         = [aws_alb_target_group.alb_http.arn]
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true

  // https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#waiting-for-capacity 参照
  desired_capacity = 1
  max_size         = 4
  min_size         = 1

  // たぶんこれを入れると EC2 Instance 起動・停止時に SNS で通知できるはず
  // https://underthehood.meltwater.com/blog/2020/02/07/dynamic-route53-records-for-aws-auto-scaling-groups-with-terraform/
  initial_lifecycle_hook {
    name                    = "lifecycle-launching"
    default_result          = "CONTINUE"
    heartbeat_timeout       = 60
    lifecycle_transition    = "autoscaling:EC2_INSTANCE_LAUNCHING"
    notification_target_arn = data.terraform_remote_state.remote_sns_email.outputs.sns_email_arn
    role_arn                = aws_iam_role.sns_email.arn
  }

  initial_lifecycle_hook {
    name                    = "lifecycle-terminating"
    default_result          = "CONTINUE"
    heartbeat_timeout       = 60
    lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
    notification_target_arn = data.terraform_remote_state.remote_sns_email.outputs.sns_email_arn
    role_arn                = aws_iam_role.sns_email.arn
  }

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "${var.project_name}-asg"
  }
}
// cloudposse/terraform-aws-ec2-autoscale-group
// https://github.com/cloudposse/terraform-aws-ec2-autoscale-group を参考にした
resource "aws_autoscaling_policy" "asg_scaling_policy_scale_up" {
  name                   = "${var.project_name}-asg-scaling-policy-scale-up"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
}
resource "aws_autoscaling_policy" "asg_scaling_policy_scale_down" {
  name                   = "${var.project_name}-asg-scaling-policy-scale-down"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
}
resource "aws_cloudwatch_metric_alarm" "asg_scale_up_alarm" {
  alarm_name          = "${var.project_name}-asg-scale-up-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "${var.project_name}-asg-scale-up-alarm"
  alarm_actions     = [aws_autoscaling_policy.asg_scaling_policy_scale_up.arn]
}
resource "aws_cloudwatch_metric_alarm" "asg_scale_down_alarm" {
  alarm_name          = "${var.project_name}-asg-scale-down-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "${var.project_name}-asg-scale-down-alarm"
  alarm_actions     = [aws_autoscaling_policy.asg_scaling_policy_scale_down.arn]
}
