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
resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.project_name}-redis-subnet-group"
  subnet_ids = [aws_subnet.private_0.id, aws_subnet.private_1.id]
}
resource "aws_elasticache_replication_group" "example" {
  replication_group_id          = "${var.project_name}-rep-group"
  replication_group_description = "${var.project_name} replication group"
  // Redis のノードタイプ固有のパラメータ
  // https://docs.aws.amazon.com/ja_jp/AmazonElastiCache/latest/red-ug/ParameterGroups.Redis.html#ParameterGroups.Redis.NodeSpecific
  node_type                  = "cache.m3.medium"
  port                       = var.redis_port
  parameter_group_name       = "default.redis5.0"
  automatic_failover_enabled = true
  number_cache_clusters      = 3
  subnet_group_name          = aws_elasticache_subnet_group.this.name
  snapshot_window            = "17:10-18:10"
  snapshot_retention_limit   = 7
  maintenance_window         = "Mon:18:10-Mon:19:10"
  apply_immediately          = false
  security_group_ids         = [aws_security_group.sg_redis.id]
}

// インストール後 Public Subnet 内の EC2 Instance で以下のコマンドを実行して動作確認する
// sudo amazon-linux-extras install redis4.0
// redis-cli -h <endpoint> -p 6379
