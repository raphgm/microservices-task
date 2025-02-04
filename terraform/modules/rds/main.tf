
resource "aws_default_security_group" "default-sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]

  }  
  

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    

  }


  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = [ ]
  }

  tags = { 
      Name = "${var.env_prefix}-default-sg"
  }

}

resource "aws_db_instance" "rds" {
  engine                = var.engine
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  db_name               = var.db_name
  username              = var.username
  password              = var.password
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  #db_subnet_group_name  = var.db_subnet_group_name
  #multi_az              = var.multi_az
}



#resource "aws_db_subnet_group" "db_subnet_group" {
  #name       = "my-db-subnet-group"
  #subnet_ids = var.subnet_ids  # List of subnet IDs for the DB subnets
  #description = "My DB Subnet Group"

  #tags = {
  #  Name = "my-db-subnet-group"
 # }
#}


resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "my-single-db-subnet-group"
  subnet_ids = [var.subnet_id]  # Only one subnet here
  description = "My DB Subnet Group with a single subnet"

  tags = {
    Name = "my-single-db-subnet-group"
  }
}
