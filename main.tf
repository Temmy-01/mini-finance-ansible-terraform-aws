# -----------------------------
# Provider
# -----------------------------
provider "aws" {
  region = "us-east-1"
}

# -----------------------------
# VPC
# -----------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "mini-finance-vpc"
  }
}

# -----------------------------
# Subnet
# -----------------------------
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "mini-finance-subnet"
  }
}

# -----------------------------
# Internet Gateway
# -----------------------------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "mini-finance-igw"
  }
}

# -----------------------------
# Route Table
# -----------------------------
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "mini-finance-rt"
  }
}

# -----------------------------
# Route Table Association
# -----------------------------
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.rt.id
}

# -----------------------------
# Security Group
# -----------------------------
resource "aws_security_group" "sg" {
  name   = "mini-finance-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mini-finance-sg"
  }
}

# -----------------------------
# EC2 Instance (Ubuntu)
# -----------------------------
resource "aws_instance" "vm" {
  ami           = "ami-08c40ec9ead489470" # Ubuntu 20.04 LTS in us-east-1
  instance_type = "t2.micro"

  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.sg.id]

  # Use existing AWS key
  key_name = "mini-finance-key"

  associate_public_ip_address = true

  tags = {
    Name = "mini-finance-vm"
  }
}

# -----------------------------
# Output Public IP
# -----------------------------
output "public_ip" {
  value = aws_instance.vm.public_ip
}