# Variables specific to this module

variable "environment" {
  default = "dev"
}

variable "instance_type" {
  type = "map"

  default = {
    dev  = "t2.micro"
    test = "t2.medium"
    prod = "t2.large"
  }
}

variable "vpc_id" {}
variable "subnet_id" {}
variable "name" {}

variable "extra_sgs" {
  default = []
}

# RDS
variable "storage_type" {
  type = "map"

  default = {
    dev = "standard"
    test = "gp2"
    prod = "io1"
  }
}

variable "allocated_storage" {
  default = "5"
}

variable "dbengine" {
  default = "mysql"
}

variable "engine_version" {
  default = "5.6.17"
}
