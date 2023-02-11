module "gitlab_instance" {
  source          = "./modules/instances/"
  instance_type   = "t2.large" #<<<<
  instance_number = 2
  subnet_id       = var.subnet_id
  vpc_id          = var.vpc_id
}

output "public_dns_address" {
  value = module.gitlab_instance.public_dns_address
}

output "instance_root_password" {
  value = module.gitlab_instance.generated_root_password
}
