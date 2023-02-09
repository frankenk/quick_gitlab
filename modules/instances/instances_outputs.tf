output "public_ip_address" {
    value = [for i in aws_instance.gitlab_instance: i.public_ip]
}
