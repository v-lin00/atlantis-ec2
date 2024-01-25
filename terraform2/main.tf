terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.16.2"
    }
  }

  required_version = ">= 1.5.1"

  backend "s3" {
    bucket         = "terraform-state-files-playground"
    key            = "bitbucket_pipeline.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform_state_vlin"
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_vpc" "nq_my_vpc" {
  cidr_block           = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "terraform_bitbucket_vpc"
  }
}

resource "aws_subnet" "pipeline_public_subnet" {
  count             = 3
  vpc_id            = aws_vpc.nq_my_vpc.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = element(["eu-west-2a", "eu-west-2b", "eu-west-2c"], count.index)

  map_public_ip_on_launch = true
}

resource "aws_subnet" "pipeline_private_subnet" {
  count             = 3
  vpc_id            = aws_vpc.nq_my_vpc.id
  cidr_block        = "10.0.${count.index + 3}.0/24"
  availability_zone = element(["eu-west-2a", "eu-west-2b", "eu-west-2c"], count.index)
}

resource "aws_internet_gateway" "bitbucket_my_igw" {
  vpc_id = aws_vpc.nq_my_vpc.id
}

resource "aws_route_table_association" "public_subnet_table_associate" {
subnet_id      = aws_subnet.pipeline_public_subnet[count.index].id
count          = 3
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_table_association" {
  subnet_id      = aws_subnet.pipeline_private_subnet[count.index].id
  count          = 3 
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.nq_my_vpc.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.nq_my_vpc.id
}

resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.bitbucket_my_igw.id
}

resource "aws_route" "nat_private_local_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.my_nat_gateway.id
}

resource "aws_security_group" "my_ec2_sg" {
  name        = "bitbucket-tf-sg"
  description = "My EC2 Security Group"
  vpc_id      = aws_vpc.nq_my_vpc.id

  # Modify these ingress rules to limit access as needed
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with trusted IP ranges
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with trusted IP ranges
  }
  
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define your EC2 instance
resource "aws_instance" "bitbucket_ec2_instance" {
  ami           = var.ami_id  # Provide the appropriate AMI ID
  instance_type = var.instance_type  # Provide the desired instance type
  subnet_id     = aws_subnet.pipeline_public_subnet[0].id
  associate_public_ip_address = true 
  vpc_security_group_ids = [aws_security_group.my_ec2_sg.id]
  key_name = aws_key_pair.bit_to_ec2_key.key_name
  user_data = "${file("user_data_ec2.tpl")}"
}

resource "aws_instance" "ec2_monitor" {
  ami           = var.ami_id  # Replace with your AMI ID
  instance_type = var.instance_type      # Choose an appropriate instance type
  subnet_id     = aws_subnet.pipeline_private_subnet[0].id  # Use one of the private subnets
  vpc_security_group_ids = [ aws_security_group.my_ec2_sg.id ]
  user_data = "${file("user_data_monitor.tpl")}"
}

resource "aws_key_pair" "bit_to_ec2_key" {
  key_name = "bit_to_ec2_key"
  public_key = tls_private_key.rsa.public_key_openssh
  
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_eip" "nat_eip" {}

resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.pipeline_public_subnet[0].id
}