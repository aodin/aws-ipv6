provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

variable "aws_region" {
  type    = "string"
  default = "us-west-2"
}

variable "aws_profile" {
  type    = "string"
  default = ""
}

variable "key_name" {
  type    = "string"
  default = "ipv6_key"
}

# Ubuntu AMIs from https://cloud-images.ubuntu.com/locator/ec2/
variable "instance_ami" {
  type    = "string"
  default = "ami-22741f5a" # Ubuntu 18.04 HVM/EBS in us-west-2
}

variable "instance_size" {
  type    = "string"
  default = "t2.nano"
}

data "aws_availability_zones" "available" {}

data "template_file" "userdata" {
  template = "${file("userdata.tpl")}"

  vars {}
}

# AWS will assign the VPC an IPv6 CIDR with a prefix length of /56
resource "aws_vpc" "ipv6_vpc" {
  cidr_block                       = "10.16.0.0/16"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true

  tags {
    Name = "ipv6_vpc"
  }
}

# The subnet IPv6 CIDR must be in the VPC CIDR and have a prefix length of /64
resource "aws_subnet" "public_ipv6" {
  vpc_id          = "${aws_vpc.ipv6_vpc.id}"
  cidr_block      = "${cidrsubnet(aws_vpc.ipv6_vpc.cidr_block, 4, 0)}"
  ipv6_cidr_block = "${cidrsubnet(aws_vpc.ipv6_vpc.ipv6_cidr_block, 8, 0)}"

  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = true

  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "public_ipv6"
  }
}

# The security group must allow ingress and egress from IPv6
resource "aws_security_group" "ipv6_security" {
  name        = "ipv6_security"
  description = "IPv6 Security"
  vpc_id      = "${aws_vpc.ipv6_vpc.id}"

  revoke_rules_on_delete = true

  tags {
    Name = "ipv6_security"
  }

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
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.ipv6_vpc.id}"

  tags {
    Name = "ipv6_gateway"
  }
}

resource "aws_route_table" "ipv6_route_table" {
  vpc_id = "${aws_vpc.ipv6_vpc.id}"

  # Route all IPv6 traffic to the Internet gateway
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = "${aws_internet_gateway.default.id}"
  }

  # Route all IPv4 traffic to the Internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "ipv6_subnet"
  }
}

# The route table must be associated with the subnet
resource "aws_route_table_association" "public_ipv6" {
  subnet_id      = "${aws_subnet.public_ipv6.id}"
  route_table_id = "${aws_route_table.ipv6_route_table.id}"
}

resource "aws_instance" "ipv6_instance" {
  ami           = "${var.instance_ami}"
  instance_type = "${var.instance_size}"
  key_name      = "${var.key_name}"
  subnet_id     = "${aws_subnet.public_ipv6.id}"

  vpc_security_group_ids      = ["${aws_security_group.ipv6_security.id}"]
  associate_public_ip_address = true
  user_data                   = "${data.template_file.userdata.rendered}"

  tags {
    Name = "ipv6_instance"
  }
}
