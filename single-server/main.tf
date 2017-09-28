# Configure a provider
provider "aws" {
  region = "us-west-2"
}

# Configure an AWS VPC
resource "aws_vpc" "nonagon-vpc-1" {
  cidr_block = "10.0.0.0/16"
}

# A subnet for the configured VPC
resource "aws_subnet" "nonagon-subnet-1" {
  vpc_id     = "${aws_vpc.nonagon-vpc-1.id}"
  depends_on = ["aws_vpc.nonagon-vpc-1"]

  cidr_block = "10.0.1.0/24"
}

# Create a security group
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP traffic"
  vpc_id      = "${aws_vpc.nonagon-vpc-1.id}"

  ingress {
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
}

resource "aws_instance" "nonagon-srv-1" {
  ami                    = "ami-efd0428f"
  instance_type          = "t2.micro"
  subnet_id              = "${aws_subnet.nonagon-subnet-1.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_http.id}"]
}

# Configure an EC2 instance
resource "aws_instance" "chp1-1" {
  ami           = "ami-efd0428f"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.nonagon-subnet-1.id}"

  tags {
    Name = "Master server"
  }
}

# Configure an EC2 instance with a dependency
resource "aws_instance" "chp1-2-slave" {
  ami           = "ami-efd0428f"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.nonagon-subnet-1.id}"
  depends_on    = ["aws_instance.chp1-1"]

  tags {
    Name = "Slave Server"
  }
}
