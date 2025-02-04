/*resource "aws_subnet" "myapp-subnet" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name: var.env_prefix
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  #vpc_id = var.vpc_id
  vpc_id = aws_vpc.myapp-vpc.id
  tags = { 
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_default_route_table" "main-rtb" {
  #default_route_table_id = var.default_route_table_id
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = { 
    Name = "${var.env_prefix}-main-rtb"
  }
}


resource "aws_default_security_group" "default-sg" {
  #vpc_id = var.vpc_id.id
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.env_prefix]
  }

  ingress {
    from_port = 8080
    to_port = 8080
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

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = [var.image_name]
    #values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_key_pair" "ssh-key" {
    key_name = "server-key"
    public_key = file(var.public_key_location)
}

resource "aws_instance" "frontend-instance" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id = module.myapp-subnet.subnet.id
  vpc_security_group_ids = [aws_default_security_group.default_sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  user_data = file("entryscrpit.sh")

  /*user_data = <<-EOF
    #!/bin/bash
    cd /var/www/html
    git clone https://github.com/Abbeyo01/spring-boot-react-example.git
    cd frontend
    npm install
    npm run build
  EOF

  tags = { 
    Name = "${var.env_prefix}-SpringBootFrontend"
  }
}
*/



/////////////////////

provider "aws" {}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

module "myapp-subnet" {
  source                 = "./modules/subnet"
  vpc_cidr_block = var.vpc_cidr_block
  subnet_cidr_block      = var.subnet_cidr_blocks
  avail_zone             = var.avail_zone
  env_prefix             = var.env_prefix
  vpc_id                 = aws_vpc.myapp-vpc.id
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  #default_route_table_id = module.vpc.default_route_table_id
  #vpc_id = aws_vpc.myapp-vpc.id

}

module "ec2_instance" {
  source            = "./modules/ec2_instance"
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  my_ip = var.my_ip
  vpc_id = aws_vpc.myapp-vpc.id
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  subnet_id = module.myapp-subnet.subnet
  image_name = var.image_name
  public_key_location = var.public_key_location
  instance_type = var.instance_type
}


module "rds" {
  source             = "./modules/rds"
  my_ip = var.my_ip
  vpc_id = aws_vpc.myapp-vpc.id
  env_prefix = var.env_prefix
  engine             = var.engine
  instance_class     = var.instance_class
  allocated_storage  = var.allocated_storage
  db_name            = var.db_name
  username           = var.username
  password           = var.password
  subnet_id = module.myapp-subnet.subnet

}

module "cloudwatch" {
  source         = "./modules/cloudwatch"
  #monitored_instance_ids = [module.ec2_instance.frontend-instance.instance_id]
  env_prefix = var.env_prefix
  #instance_id = module.ec2_instance.frontend-instance_id
  frontend_instance_id = module.ec2_instance.frontend_instance_id
  backend_instance_id = module.ec2_instance.backend_instance_id
  jenkins_instance_id = module.ec2_instance.jenkins_instance_id
  rds_instance_id = module.rds.rds_instance_id
  #DBInstanceIdentifier = module.rds.aws_db_instance
  

}
