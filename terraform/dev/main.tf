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