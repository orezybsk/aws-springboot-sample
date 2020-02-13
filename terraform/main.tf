terraform {
  required_version = "0.12.20"

  // https://www.terraform.io/docs/backends/types/s3.html 参照。
  // backend では var.～ は使用できない
  backend "s3" {
    bucket = "orezybsk-terraform-backend"
    key    = "aws-springboot-sample/terraform.tfstate"
    region = "ap-northeast-1"

    dynamodb_table = "orezybsk-terraform-backend-lock"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

///////////////////////////////////////////////////////////////////////////////
// VPC
//
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

///////////////////////////////////////////////////////////////////////////////
// Internet Gateway
//
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

///////////////////////////////////////////////////////////////////////////////
// Subnet (public_0), Route Table
//
resource "aws_subnet" "public_0" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-0"
  }
}
resource "aws_route_table" "public_0" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_route" "public_0" {
  route_table_id         = aws_route_table.public_0.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route_table_association" "public_0" {
  subnet_id      = aws_subnet.public_0.id
  route_table_id = aws_route_table.public_0.id
}

///////////////////////////////////////////////////////////////////////////////
// Subnet (public_1), Route Table
//
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-1"
  }
}
resource "aws_route_table" "public_1" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_route" "public_1" {
  route_table_id         = aws_route_table.public_1.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_1.id
}

///////////////////////////////////////////////////////////////////////////////
// Subnet (private_0), Route Table
//
resource "aws_subnet" "private_0" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.64.0/24"
  availability_zone       = "ap-northeast-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-0"
  }
}
resource "aws_route_table" "private_0" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_route_table_association" "private_0" {
  subnet_id      = aws_subnet.private_0.id
  route_table_id = aws_route_table.private_0.id
}

///////////////////////////////////////////////////////////////////////////////
// Subnet (private_1), Route Table
//
resource "aws_subnet" "private_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.65.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-1"
  }
}
resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}

///////////////////////////////////////////////////////////////////////////////
// VPC Endpoint (ssm, ec2messages, ssmmessages)
// 作成完了まで 1:30～2:00 程かかる
//
resource "aws_security_group" "ssm_vpc_endpoint" {
  name   = "${var.project_name}-sg-ssm-vpc-endpoint"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "ssm_vpc_endpoint" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.ap-northeast-1.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  // vpc_endpoint_type = "Interface" の時は route_table_ids は設定できないので
  // subnet_ids を設定する
  subnet_ids         = [aws_subnet.public_0.id, aws_subnet.public_1.id]
  security_group_ids = [aws_security_group.ssm_vpc_endpoint.id]

  tags = {
    Name = "${var.project_name}-ssm-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2messages_vpc_endpoint" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.ap-northeast-1.ec2messages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.public_0.id, aws_subnet.public_1.id]
  security_group_ids  = [aws_security_group.ssm_vpc_endpoint.id]

  tags = {
    Name = "${var.project_name}-ec2messages-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssmmessages_vpc_endpoint" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.ap-northeast-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.public_0.id, aws_subnet.public_1.id]
  security_group_ids  = [aws_security_group.ssm_vpc_endpoint.id]

  tags = {
    Name = "${var.project_name}-ssmmessages-vpc-endpoint"
  }
}
