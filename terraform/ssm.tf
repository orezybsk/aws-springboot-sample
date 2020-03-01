///////////////////////////////////////////////////////////////////////////////
// SSM Parameter Store
//
resource "aws_ssm_parameter" "SPRING_DATASOURCE_HIKARI_JDBC_URL" {
  count = var.create_rds ? 1 : 0

  # Requirements and Constraints for Parameter Names
  # https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-parameter-name-constraints.html
  # ※parameter は "aws" から始められない
  name = "/springbootSample/${var.profile}/SPRING_DATASOURCE_HIKARI_JDBC_URL"
  type = "SecureString"
  value = format("jdbc:mysql://%s/%s?sslMode=DISABLED&characterEncoding=utf8",
    element(split(":", aws_db_instance.this[count.index].endpoint), 0),
    var.db_name
  )
  key_id = aws_kms_key.this.id
}

# Call to function "element" failed: cannot read elements from set of string
# https://github.com/hashicorp/terraform/issues/22392
resource "aws_ssm_parameter" "SPRING_REDIS_CLUSTER_NODES" {
  count = (var.redis_replicas_per_node_group + 1) * var.redis_num_node_groups

  name = "/springbootSample/${var.profile}/SPRING_REDIS_CLUSTER_NODES_${count.index}"
  type = "SecureString"
  value = format("%s.%s:%s",
    sort(aws_elasticache_replication_group.this.member_clusters)[count.index],
    replace(replace(aws_elasticache_replication_group.this.configuration_endpoint_address,
      format("%s.", aws_elasticache_replication_group.this.replication_group_id), ""
    ), "clustercfg", "0001"),
    var.redis_port
  )
  key_id = aws_kms_key.this.id
}
