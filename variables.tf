variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "subnet_id" {
  description = "Change to your desired subnet - leave empty for default"
  type = string
  default = ""
}

variable "vpc_id" {
  description = "Change to your desired VPC ID - leave empty for default"
  type = string
  default = ""
}