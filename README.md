# aws-springboot-sample
AWS で EC2＋RDS＋ElastiCache 構成のサンプルを作成する

* gradle ディレクトリ, gradlew, gradlew.bat をコピーして `gradle init` コマンドを実行する。 
* terraform を実行する時の IAM User, IAM Role、及び backend で使用する S3 Bucket、DynamoDB のテーブルを作成する。
  * terraform-init ディレクトリを作成し、main.tf, variables.tf に IAM User, IAM Role, S3 Bucket, DynamoDB のテーブルを記述する。
  * variables.tf に記述した変数の値はルート直下に .envrc を作成し、export TF_VAR_<variable>=<value> のフォーマットで定義する。
