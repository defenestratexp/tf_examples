variable "region" {
  description = "AWS Region. Changing this could break the system"
  default     = "us-west-2"
}

variable "environment" {
  default = "prod"
}
