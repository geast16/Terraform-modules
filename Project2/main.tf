provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket  = "ecom-ge-2024"
    key     = "ecom/terraform_project"
    region  = "us-east-1"
    encrypt = true
  }
}

resource "aws_vpc" "ecom_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "ECom VPC"
  }
}
resource "aws_internet_gateway" "ecom_igw" {
  vpc_id = aws_vpc.ecom_vpc.id
  tags = {
    Name = "ECom IGW"
  }
}
resource "aws_route" "ecom_igw_route" {
  route_table_id         = aws_vpc.ecom_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ecom_igw.id
}
resource "aws_subnet" "ecom_subnet" {
  count                   = length(var.subnet_cidr)
  vpc_id                  = aws_vpc.ecom_vpc.id
  cidr_block              = var.subnet_cidr[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "ECom Subnet ${count.index + 1}"
  }
}
resource "aws_security_group" "ecom_sg" {
  vpc_id = aws_vpc.ecom_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ECom SG"
  }
}
# Generate a new private key
resource "tls_private_key" "ecom_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Create an AWS key pair using the generated public key
resource "aws_key_pair" "ecom_key" {
  key_name   = "ecom-prod"
  public_key = tls_private_key.ecom_key.public_key_openssh
}
# Save the private key locally for SSH access
resource "local_file" "ecom_private_key" {
  content  = tls_private_key.ecom_key.private_key_pem
  filename = "${path.module}/ecom-prod.pem"
  provisioner "local-exec" {
    command = "chmod 400 ${path.module}/ecom-prod.pem"
  }
}
resource "aws_launch_configuration" "ecom_lc" {
  name            = "ecom-launch-config"
  image_id        = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [aws_security_group.ecom_sg.id]
  user_data       = file(var.ecom_user_data_file)
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_key_pair.ecom_key]
}
resource "aws_autoscaling_group" "ecom_asg" {
  launch_configuration = aws_launch_configuration.ecom_lc.name
  min_size             = 2
  max_size             = 5
  desired_capacity     = 2
  vpc_zone_identifier  = aws_subnet.ecom_subnet.*.id
  tag {
    key                 = "Ecom-ASG"
    value               = "true"
    propagate_at_launch = true
  }
}
