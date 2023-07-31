provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

variable "aws_region" {
  default = "us-west-2"
}

variable "aws_profile" {
  default = ""
}

variable "key_name" {
  default = "ipv6_key"
}

# Ubuntu AMIs from https://cloud-images.ubuntu.com/locator/ec2/
variable "instance_ami" {
  default = "ami-06edaf01ee52adb1e" # Ubuntu 22.04 LTS arm64 in us-west-2
}

variable "instance_size" {
  default = "t4g.nano"
}

data "aws_availability_zones" "available" {}

# AWS will assign the VPC an IPv6 CIDR with a prefix length of /56
resource "aws_vpc" "ipv6_vpc" {
  cidr_block                       = "10.16.0.0/16"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "ipv6_vpc"
  }
}

# The subnet IPv6 CIDR must be in the VPC CIDR and have a prefix length of /64
resource "aws_subnet" "public_ipv6" {
  vpc_id          = aws_vpc.ipv6_vpc.id
  cidr_block      = cidrsubnet(aws_vpc.ipv6_vpc.cidr_block, 4, 0)
  ipv6_cidr_block = cidrsubnet(aws_vpc.ipv6_vpc.ipv6_cidr_block, 8, 0)

  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = true

  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "public_ipv6"
  }
}

# The security group must allow ingress and egress from IPv6
resource "aws_security_group" "ipv6_security" {
  name        = "ipv6_security"
  description = "IPv6 Security"
  vpc_id      = aws_vpc.ipv6_vpc.id

  revoke_rules_on_delete = true

  # Allow connections from any IPv4 or IPv6 address; this is not secure
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ipv6_security"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.ipv6_vpc.id

  tags = {
    Name = "ipv6_gateway"
  }
}

resource "aws_route_table" "ipv6_route_table" {
  vpc_id = aws_vpc.ipv6_vpc.id

  # Route all IPv6 traffic to the Internet gateway
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.default.id
  }

  # Route all IPv4 traffic to the Internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "ipv6_subnet"
  }
}

# The route table must be associated with the subnet
resource "aws_route_table_association" "public_ipv6" {
  subnet_id      = aws_subnet.public_ipv6.id
  route_table_id = aws_route_table.ipv6_route_table.id
}

resource "aws_instance" "ipv6_instance" {
  ami           = var.instance_ami
  instance_type = var.instance_size
  key_name      = var.key_name
  subnet_id     = aws_subnet.public_ipv6.id

  vpc_security_group_ids      = [aws_security_group.ipv6_security.id]
  associate_public_ip_address = true

  tags = {
    Name = "ipv6_instance"
  }
}
