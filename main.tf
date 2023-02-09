module "gitlab_instance" {
  source        = "./modules/instances/"
  instance_type = "t2.medium"
  instance_number = 1
  subnet_id     = var.subnet_id 
  vpc_id = var.vpc_id
}

output "public_ip_address" {
    value = module.gitlab_instance.public_ip_address
}

output "instance_root_password" {
    value = module.gitlab_instance.generated_root_password
}
