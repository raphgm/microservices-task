resource "aws_subnet" "myapp-subnet" {
  vpc_id = var.vpc_id #correct one
  #vpc_id = aws_vpc.myapp-vpc.id  # not correct but using it to test run
  cidr_block = var.vpc_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name: var.env_prefix
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = var.vpc_id
  tags = { 
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = var.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = { 
    Name = "${var.env_prefix}-main-rtb"
  }
}