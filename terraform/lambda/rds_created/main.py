# Tutorial: Configuring a Lambda Function to Access Amazon RDS in an Amazon VPC
# https://docs.aws.amazon.com/lambda/latest/dg/services-rds-tutorial.html
# AWS Lambda Deployment Package in Python
# https://docs.aws.amazon.com/lambda/latest/dg/python-package.html
# Lambda から RDS にアクセスする方法 (python)
# https://qiita.com/aidy91614/items/92987d547c318e0483f5
# Boto 3 Documentation
# https://boto3.amazonaws.com/v1/documentation/api/latest/index.html
import sys
import pymysql


def lambda_handler(event, context):
    try:
        conn = pymysql.connect(event['RDS_ENDPOINT'],
                               user=event['DB_MASTER_USERNAME'], passwd=event['DB_MASTER_PASSWORD'],
                               db='mysql', connect_timeout=5)
        print('connect 成功')
    except:
        print('connect 失敗')
        sys.exit()

    try:
        with conn.cursor() as cur:
            # Pythonの新しい文字列フォーマット : %記号、str.format()から文字列補完へ
            # https://postd.cc/new-string-formatting-in-python/
            # pyformat.info
            # https://pyformat.info/
            cur.execute(f"create database if not exists {event['DB_NAME']} character set utf8mb4")
            cur.execute(f"create user '{event['DB_USERNAME']}'@'%' identified by '{event['DB_PASSWORD']}'")
            cur.execute(f"grant all privileges ON {event['DB_NAME']}.* to '{event['DB_USERNAME']}'@'%' with grant option")
            cur.execute(f"grant select ON performance_schema.user_variables_by_thread to '{event['DB_USERNAME']}'@'%'")
            cur.execute("flush privileges")
    finally:
        conn.close()
