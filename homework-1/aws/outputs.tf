output "ssh_command" {
  value = "ssh ubuntu@${aws_instance.web.public_dns}"
}