module "jenkins_ec2" {
  source = "../modules/jenkins-ec2"

  instance_name = "jenkins-server"
  instance_type = "t3.medium"

  ami_id   = "ami-001e7cc215773c7fb"
  key_name = "capstone-key-v2"

  vpc_id    = "vpc-03e7cf094cb107161"
  subnet_id = "subnet-0c495c93450cfc1bb"
}

module "auth_ecr" {
  source = "../modules/ecr"

  repository_name = "auth-service"
}

module "chat_ecr" {
  source = "../modules/ecr"

  repository_name = "chat-service"
}

module "frontend_ecr" {
  source = "../modules/ecr"

  repository_name = "chat-app-client"
}

module "vpc" {
  source = "../modules/vpc"

  project_name = var.project_name

  vpc_cidr = var.vpc_cidr

  public_subnet_1_cidr = var.public_subnet_1_cidr
  public_subnet_2_cidr = var.public_subnet_2_cidr

  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr

  availability_zone_1 = var.availability_zone_1
  availability_zone_2 = var.availability_zone_2
}

module "eks" {
  source = "../modules/eks"

  cluster_name = "${var.project_name}-eks"

  eks_version = var.eks_version

  private_subnet_ids = module.vpc.private_subnet_ids
}

module "rds" {
  source = "../modules/rds"

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}