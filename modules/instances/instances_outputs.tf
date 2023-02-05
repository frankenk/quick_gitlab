output "public_ip_address" {
    value = aws_instance.gitlab_instance.public_ip
}
