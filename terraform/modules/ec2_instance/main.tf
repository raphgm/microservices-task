
resource "aws_default_security_group" "default-sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

ingress {
    from_port = 8081
    to_port = 8081
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

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

resource "aws_instance" "frontend" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  #subnet_id = module.myapp-subnet.subnet.id
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  #user_data = file("entryscrpit.sh")
  user_data         = file("${path.root}/scripts/frontend-init.sh")  # Reference the script file here


  /*user_data = <<-EOF
    #!/bin/bash
    cd /var/www/html
    git clone https://github.com/Abbeyo01/spring-boot-react-example.git
    cd frontend
    npm install
    npm run build
  EOF*/

  tags = { 
    Name = "${var.env_prefix}-SpringBootFrontend"
  }
}

resource "aws_instance" "backend" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  #subnet_id = module.myapp-subnet.subnet.id
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  user_data = <<-EOF
    #!/bin/bash
    cd /var/www/backend
    git clone https://github.com/Abbeyo01/spring-boot-react-example.git
    cd backend
    npm install
    npm start
  EOF
  

  tags = { 
    Name = "${var.env_prefix}-SpringBootFrontend"
  }
}

resource "aws_instance" "jenkins" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  #subnet_id = module.myapp-subnet.subnet.id
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install -y openjdk-11-jdk
    wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
    sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    sudo apt update
    sudo apt install -y jenkins
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
  EOF

  tags = {
    Name = "Jenkins"
  }
}