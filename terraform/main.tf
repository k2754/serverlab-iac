terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-3"
}

resource "aws_vpc" "tf_lab_vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "tf-lab-vpc"
  }
}

resource "aws_subnet" "tf_lab_subnet" {
  vpc_id                  = aws_vpc.tf_lab_vpc.id
  cidr_block               = "10.1.1.0/24"
  availability_zone        = "ap-northeast-3a"
  map_public_ip_on_launch  = true
  tags = {
    Name = "tf-lab-subnet"
  }
}

resource "aws_internet_gateway" "tf_lab_igw" {
  vpc_id = aws_vpc.tf_lab_vpc.id
  tags = {
    Name = "tf-lab-igw"
  }
}

resource "aws_route_table" "tf_lab_rt" {
  vpc_id = aws_vpc.tf_lab_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_lab_igw.id
  }
  tags = {
    Name = "tf-lab-rt"
  }
}

resource "aws_route_table_association" "tf_lab_rta" {
  subnet_id      = aws_subnet.tf_lab_subnet.id
  route_table_id = aws_route_table.tf_lab_rt.id
}

resource "aws_security_group" "tf_lab_sg" {
  name   = "tf-lab-sg"
  vpc_id = aws_vpc.tf_lab_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "tf_lab_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_lab_sg.id
}
