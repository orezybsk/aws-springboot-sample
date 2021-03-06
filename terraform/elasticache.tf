///////////////////////////////////////////////////////////////////////////////
// ElastiCache (Redis)
//
// Redis 固有のパラメータ
// https://docs.aws.amazon.com/ja_jp/AmazonElastiCache/latest/red-ug/ParameterGroups.Redis.html
// terraform-community-modules/tf_aws_elasticache_redis
// https://github.com/terraform-community-modules/tf_aws_elasticache_redis
// ※作成中に見つけたのでメモ書きしておく。
resource "aws_security_group" "sg_redis" {
  name   = "${var.project_name}-sg-redis"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = var.redis_port
    protocol        = "tcp"
    to_port         = var.redis_port
    security_groups = [aws_security_group.sg_asg.arn]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_elasticache_parameter_group" "this" {
  name   = "${var.project_name}-redis-parameter-group"
  family = "redis5.0"

  parameter {
    name  = "cluster-enabled"
    value = "yes"
  }

  parameter {
    name  = "notify-keyspace-events"
    value = "Egx"
  }
}
resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.project_name}-redis-subnet-group"
  subnet_ids = [aws_subnet.private_0.id, aws_subnet.private_1.id]
}
resource "aws_elasticache_replication_group" "this" {
  replication_group_id          = "${var.project_name}-rep-group"
  replication_group_description = "${var.project_name} replication group"
  // Redis のノードタイプ固有のパラメータ
  // https://docs.aws.amazon.com/ja_jp/AmazonElastiCache/latest/red-ug/ParameterGroups.Redis.html#ParameterGroups.Redis.NodeSpecific
  // node_type = "cache.m3.medium"
  node_type = "cache.t3.small"
  port      = var.redis_port
  // Spring Session を使用する時は default ではなく自分で aws_elasticache_parameter_group を定義する
  // Spring Session - 9.7.5. SessionDeletedEvent and SessionExpiredEvent
  // https://docs.spring.io/spring-session/docs/current/reference/html5/#api-redisindexedsessionrepository-sessiondestroyedevent
  // parameter_group_name = "default.redis5.0.cluster.on"
  parameter_group_name       = aws_elasticache_parameter_group.this.name
  automatic_failover_enabled = true
  subnet_group_name          = aws_elasticache_subnet_group.this.name
  snapshot_window            = "17:10-18:10"
  snapshot_retention_limit   = 7
  maintenance_window         = "Mon:18:10-Mon:19:10"
  apply_immediately          = false
  security_group_ids         = [aws_security_group.sg_redis.id]

  cluster_mode {
    replicas_per_node_group = 1
    num_node_groups         = 2
  }
}

// インストール後 Public Subnet 内の EC2 Instance で以下のコマンドを実行して動作確認する
// sudo amazon-linux-extras install redis4.0 -y
// redis-cli -h <endpoint> -p 6379 -c

///////////////////////////////////////////////////////////////////////////////
// CloudWatch
//
// azavea / terraform-aws-redis-elasticache
// https://github.com/azavea/terraform-aws-redis-elasticache/blob/develop/main.tf
resource "aws_cloudwatch_metric_alarm" "redis_cpu" {
  count = (var.redis_replicas_per_node_group + 1) * var.redis_num_node_groups

  alarm_name          = format("alarm-ElastiCache-CPUUtilization(%s)", sort(aws_elasticache_replication_group.this.member_clusters)[count.index])
  alarm_description   = "Redis Cluster CPU utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"

  threshold = 70

  dimensions = {
    CacheClusterId = sort(aws_elasticache_replication_group.this.member_clusters)[count.index]
  }

  alarm_actions = [data.terraform_remote_state.remote_sns_email.outputs.sns_email_arn]
}

resource "aws_cloudwatch_metric_alarm" "redis_freememory" {
  count = (var.redis_replicas_per_node_group + 1) * var.redis_num_node_groups

  alarm_name          = format("alarm-ElastiCache-FreeableMemory(%s)", sort(aws_elasticache_replication_group.this.member_clusters)[count.index])
  alarm_description   = "Redis Cluster freeable memory"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeableMemory"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"

  threshold = 294205259

  dimensions = {
    CacheClusterId = sort(aws_elasticache_replication_group.this.member_clusters)[count.index]
  }

  alarm_actions = [data.terraform_remote_state.remote_sns_email.outputs.sns_email_arn]
}
