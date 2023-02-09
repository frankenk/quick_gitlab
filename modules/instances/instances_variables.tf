variable "instance_type" {
  description = "Type of the instance"
  type        = string
}

variable "instance_number" {
  description = "Number of instances to create"
  type        = number
}

variable "subnet_id" {
  type = string
}

variable "vpc_id" {
  type = string
}
