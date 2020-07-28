
# Provider and EC2 instance

provider "aws" {
    access_key  = var.access_key
    secret_key  = var.secret_key
    region      = var.region 
}


resource "aws_instance" "wordpress" {
    ami                     = "ami-e51bac98"
    instance_type           = "t2.small"
    vpc_security_group_ids  = [aws_security_group.main80.id, aws_security_group.main22.id]
    subnet_id               = aws_subnet.main.id
}


# Architecture


    # VPC
resource "aws_vpc" "main" {
    cidr_block  = "10.0.0.0/16"
}

    # Gateway
resource "aws_internet_gateway" "main" {
    vpc_id  = aws_vpc.main.id

  tags = {
    Name  = "Main"
  }
}

    # Route table
resource "aws_route_table" "main" {
  vpc_id    = aws_vpc.main.id

  route {
    cidr_block  = "0.0.0.0/0"
    gateway_id  = aws_internet_gateway.main.id
  }
 
}

    # Subnet
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name  = "Main"
  }
}


    # Security groups, ports 80 and 22
resource "aws_security_group" "main80" {

  name      = "wp_cloudcoach80"
  vpc_id    = aws_vpc.main.id

  ingress {
    from_port     = 80
    to_port       = 80
    protocol      = "tcp"
    cidr_blocks   = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name  = "Main"
  }
 }

 resource "aws_security_group" "main22" {

  name      = "wp_cloudcoach22"
  vpc_id    = aws_vpc.main.id

  ingress {
    from_port     = 22
    to_port       = 22
    protocol      = "tcp"
    cidr_blocks   = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Main"
  }
 }

    #Network ACL
resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main.id

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = aws_vpc.main.cidr_block
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = aws_vpc.main.cidr_block
    from_port  = 80
    to_port    = 80
  }

  tags = {
    Name = "main"
  }
}


# Outputs

output "public_ip" {
    value   = aws_instance.wordpress.public_ip
}

