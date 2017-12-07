# Everything an application might require can go in a module

#################
### INSTANCES ###
#################

resource "aws_instance" "nonagon-django" {
  ami                    = "ami-efd0428f"
  instance_type          = "${lookup(var.instance_type, var.environment)}"
  subnet_id              = "${var.subnet_id}"
  #vpc_security_group_ids = ["${aws_security_group.web_allow_http.id}"]

  tags {
    Name = "${var.name}"
  }
}

###########
### RDS ###
###########

resource "aws_db_instance" "djangodb" {
  allocated_storage    = "${var.allocated_storage}"
  storage_type         = "${lookup(var.storage_type, var.environment)}"
  engine               = "${var.dbengine}"
  engine_version       = "${engine_version}"
  instance_class       = "db.t1.micro"
  name                 = "djangodb1"
  username             = "django"
  password             = "R0ck3s+!srv90x1djangodbpass"
}

###############
### OUTPUTS ###
###############

output "hostname" {
  value = "${aws_instance.nonagon-web.private_dns}"
}
