output "jenkins_public_ip" {
  value = module.jenkins_ec2.public_ip
}

output "auth_ecr_url" {
  value = module.auth_ecr.repository_url
}

output "chat_ecr_url" {
  value = module.chat_ecr.repository_url
}