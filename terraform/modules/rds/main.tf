resource "aws_security_group" "rds" {
  name        = "${var.db_name}-rds-sg"
  description = "RDS Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "this" {
  name = "${var.db_name}-subnet-group"

  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "this" {
  identifier = var.db_name

  engine         = "mysql"
  engine_version = "8.0"

  instance_class = "db.t3.micro"

  allocated_storage = 20

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  skip_final_snapshot = true

  publicly_accessible = false

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  db_subnet_group_name = aws_db_subnet_group.this.name
}