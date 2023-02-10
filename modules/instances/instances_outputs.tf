output "public_dns_address" {
    value = [for i in aws_instance.gitlab_instance: i.public_dns]
}

output "generated_root_password" {
  value = random_string.gitlab_root_password.result
}