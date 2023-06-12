### !!! Read Me First !!! ###
# This project is for display purposes only #
# This file is designed only as a representation of the architecture used #
### !!! Thank You !!! ###

# RDS/Aurora-MySQL database cluster (Aurora Serverless)
resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier     = "coffee-web-db-cluster"
  engine                 = "aurora-mysql"
  engine_mode            = "provisioned"
  engine_version         = "8.0"
  master_username        = "admin"
  master_password        = "12345678"   # !! Password Must be set to random before use !! #
  database_name          = "wordpress"
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.aws_db_subnet_group.name
  skip_final_snapshot    = true
  serverlessv2_scaling_configuration {
    max_capacity = 2
    min_capacity = 0.5
  }
}

#  RDS database instance
resource "aws_rds_cluster_instance" "rds_cluster" {
  cluster_identifier = aws_rds_cluster.rds_cluster.cluster_identifier
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.rds_cluster.engine
  engine_version     = aws_rds_cluster.rds_cluster.engine_version

}

# Private RDS database subnet for east-1a  & east-1b
resource "aws_db_subnet_group" "aws_db_subnet_group" {
  name       = "coffe_aws_db_subnet_group"
  subnet_ids = [aws_subnet.pvt_sbnet_rds_1a.id, aws_subnet.pvt_sbnet_rds_1b.id]
}

# Security group for the Aurora-MySQL/RDS database
resource "aws_security_group" "rds_sg" {
  name        = "coffee_rds_sg"
  description = "RDS database security group"

  vpc_id = aws_vpc.main.id

#######  Caution #######  Caution #######  Caution ####### 
# The databse is currently set to "wide open" # 
# These must be changed to MySQL port number and subnets only # 
#######  Caution #######  Caution #######  Caution ####### 
  
 # Incoming traffic from the web servers
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"           # The databse is currently set to "wide open" #   
    cidr_blocks = ["0.0.0.0/0"] # Subnet CIDR blocks
  }

  # Outgoing traffic to the web servers
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Subnet CIDR blocks
  }
}

#######  Caution #######  Caution #######  Caution ####### 
# The databse is currently set to "wide open" # 
# These must be changed to MySQL port number and subnets only # 
#######  Caution #######  Caution #######  Caution ####### 
  
