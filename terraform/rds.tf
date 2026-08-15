resource "aws_db_subnet_group" "project_bedrock" {
  name = "project-bedrock-db-subnet-group"

  subnet_ids = module.vpc.private_subnets

  tags = merge(local.common_tags, {
    Name = "project-bedrock-db-subnet-group"
  })
}

resource "aws_security_group" "rds" {
  name        = "project-bedrock-rds-sg"
  description = "Security group for Project Bedrock RDS databases"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "MySQL from EKS nodes"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  ingress {
    description     = "PostgreSQL from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "project-bedrock-rds-sg"
  })
}

resource "random_password" "catalog" {
  length  = 24
  special = true
}

resource "random_password" "orders" {
  length  = 24
  special = true
}

resource "aws_db_instance" "catalog" {
  identifier = "project-bedrock-catalog"

  engine = "mysql"

  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "catalog"
  username = "catalog_admin"
  password = random_password.catalog.result

  db_subnet_group_name   = aws_db_subnet_group.project_bedrock.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false

  backup_retention_period = 1
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  multi_az = false

  skip_final_snapshot = true
  deletion_protection = false

  tags = merge(local.common_tags, {
    Name = "project-bedrock-catalog"
  })
}

resource "aws_db_instance" "orders" {
  identifier = "project-bedrock-orders"

  engine = "postgres"

  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "orders"
  username = "orders_admin"
  password = random_password.orders.result

  db_subnet_group_name   = aws_db_subnet_group.project_bedrock.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false

  backup_retention_period = 1
  backup_window           = "04:00-05:00"
  maintenance_window      = "sun:05:00-sun:06:00"

  multi_az = false

  skip_final_snapshot = true
  deletion_protection = false

  tags = merge(local.common_tags, {
    Name = "project-bedrock-orders"
  })
}
