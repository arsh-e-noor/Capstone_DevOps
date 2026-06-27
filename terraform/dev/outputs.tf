output "jenkins_public_ip" {
  value = module.jenkins_ec2.public_ip
}

output "auth_ecr_url" {
  value = module.auth_ecr.repository_url
}

output "chat_ecr_url" {
  value = module.chat_ecr.repository_url
}

output "frontend_ecr_url" {
  value = module.frontend_ecr.repository_url
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnet_ids
}

output "public_subnets" {
  value = module.vpc.public_subnet_ids
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}