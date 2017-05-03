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

# Reference the application in the main template
module "n9n-web-srv-1" {
  source    = "./modules/web-server"
  vpc_id    = "${aws_vpc.nonagon-vpc-1.id}"
  subnet_id = "${aws_subnet.nonagon-subnet-1.id}"
  name      = "nonagon-web-1"
}

module "n9n-web-srv-2" {
  source    = "./modules/web-server"
  vpc_id    = "${aws_vpc.nonagon-vpc-1.id}"
  subnet_id = "${aws_subnet.nonagon-subnet-1.id}"
  name      = "WebServer2 ${module.n9n-web-srv-1.hostname}"
  #name = "nonagon-web-2"
}
