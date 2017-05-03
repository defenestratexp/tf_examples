# Everything an application might require can go in a module

#################
### VARIABLES ###
#################
variable "vpc_id" {}

variable "subnet_id" {}
variable "name" {}

#######################
### SECURITY GROUPS ###
#######################
# A security group for the application
resource "aws_security_group" "web_allow_http" {
  name        = "web_allow_http"
  description = "Allow HTTP traffic"

  #vpc_id      = "${aws_vpc.nonagon-vpc-1.id}"
  # To access variables use the var keyword
  vpc_id = "${var.vpc_id}"

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

#################
### INSTANCES ###
#################

resource "aws_instance" "nonagon-web" {
  ami                    = "ami-efd0428f"
  instance_type          = "t2.micro"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.web_allow_http.id}"]

  tags {
    Name = "${var.name}"
  }
}

###############
### OUTPUTS ###
###############

output "hostname" {
  value = "${aws_instance.nonagon-web.private_dns}"
}
