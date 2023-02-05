module "gitlab_instance" {
  source        = "./modules/instances/"
  instance_type = "t2.medium"
}

output "public_ip_address" {
    value = module.gitlab_instance.public_ip_address
}

