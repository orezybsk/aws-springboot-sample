# aws-springboot-sample
AWS で EC2＋RDS＋ElastiCache 構成のサンプルを作成する

* gradle ディレクトリ, gradlew, gradlew.bat をコピーして `gradle init` コマンドを実行する。 
* terraform を実行する時の IAM User, IAM Role、及び backend で使用する S3 Bucket、DynamoDB のテーブルを作成する。
  * terraform-init ディレクトリを作成し、main.tf, variables.tf に IAM User, IAM Role, S3 Bucket, DynamoDB のテーブルを記述する。
  * variables.tf に記述した変数の値はルート直下に .envrc を作成し、export TF_VAR_<variable>=<value> のフォーマットで定義する。
* AWS Management Console にログインして、作成した IAM User の ACCESS_KEY_ID, SECRET_ACCESS_KEY を作成し、MFA を設定する。
* https://ksby.hatenablog.com/entry/2020/01/19/031546 を参考に設定する。
* main.tf, asg-ec2.tf に VPC, IGW, Subnet, Route Table, VPC Endpoint, ALB, ASG+EC2 を定義する。
* rds.tf に RDS(MySQL) を定義する。
* elasticache.tf に ElastiCache(Redis) を定義する。
* Spring Boot でサンプルアプリケーションを作成する。

## 残件

* ElastiCache(Redis)は、
  * CPU使用率、メモリ使用量を監視してアラームを送信するようにしたい。
  * 通信も SSL にしたい。
  * https://github.com/azavea/terraform-aws-redis-elasticache を参考にする？
* ASG, RDS, ElastiCache の監視アラームを SNS で送信するようにしたい。
