# Configure a provider
provider "aws" {
  region = "${var.region}"
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

#######################
### SECURITY GROUPS ###
#######################
# A security group for HTTP Access
resource "aws_security_group" "web_allow_http" {
  name        = "web_allow_http"
  description = "Allow HTTP traffic"

  vpc_id      = "${aws_vpc.nonagon-vpc-1.id}"
  # To access variables use the var keyword
  #vpc_id = "${var.vpc_id}"

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

# A security group for MySQL access
resource "aws_security_group" "mysql-rds" {
  name        = "MySQL"
  description = "Allow MySQL traffic"
  vpc_id      = "${aws_vpc.nonagon-vpc-1.id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

}
# A security group for external SSH access
resource "aws_security_group" "bastion_ssh" {
  name        = "External SSH SG"
  description = "Allow SSH access"
  vpc_id      = "{aws_vpc.nonagon-vpc-1}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# A security group for internal SSH access
resource "aws_security_group" "internal_ssh" {
  name        = "Internal SSH SG"
  description = "Allow internal SSH access"
  vpc_id      = "{aws_vpc.nonagon-vpc-1}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
}

# Declare resources in the web server group
# Reference the application in the main template
module "n9n-web-srv-1" {
  source    = "./modules/web-server"
  vpc_id    = "${aws_vpc.nonagon-vpc-1.id}"
  subnet_id = "${aws_subnet.nonagon-subnet-1.id}"
  name      = "nonagon-web-1"

  #environment = "${var.environment}"
  environment = "dev"
  extra_sgs   = ["${aws_security_group.default.id}", "${aws_security_group.web_allow_http.id}"]
}

# A second server would have similar resources, but a different name
# Uncomment this module to create a second server (for potential use in something like a cluster
#module "n9n-web-srv-2" {
#  source    = "./modules/web-server"
#  vpc_id    = "${aws_vpc.nonagon-vpc-1.id}"
#  subnet_id = "${aws_subnet.nonagon-subnet-1.id}"
#  name      = "WebServer2 ${module.n9n-web-srv-1.hostname}"
#
#  #environment = "${var.environment}"
#  environment = "dev"
#
#  #name = "nonagon-web-2"
#}

# Declare resources in a group for a django installation
# Reference for django server
module "n9n-django-1" {
  source    = "./modules/django-server"
  vpc_id    = "${aws_vpc.nonagon-vpc-1.id}"
  subnet_id = "${aws_subnet.nonagon-subnet-1.id}"
  name      = "nonagon-django-1"
  environment   = "dev"
  extra_sgs     = ["${aws_security_group.internal_ssh.id}", "${aws_security_group.web_allow_http.id}"]
}
