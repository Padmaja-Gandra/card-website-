terraform {
  backend "s3" {
    bucket = "padamaja-demo"
    key    = "path/terraform.tfstate"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
 provider "aws" {
  region = "us-east-1"
    
  }

# resource "aws_eip" "lb" {
  # instance = aws_instance.demo-instance.id
  # tags = {
  # Name = "eip from terraform"
#aws vpc--------------------------
  resource "aws_vpc" "main-vpc" {
  cidr_block = "10.10.0.0/16"
  tags = {
   Name ="terraform vpc"
  }
}
# aws subnet-------------------
resource "aws_subnet" "subnet-1-public" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "10.10.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "public subnet1 1a"
  }
}
resource "aws_subnet" "subnet-2-public" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "10.10.1.0/24"
   availability_zone = "us-east-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "public subnet2 1b"
  }
}
resource "aws_subnet" "subnet-3-private" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "10.10.2.0/24"
   availability_zone = "us-east-1c"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "private subnet3 1c"
  }
}


resource "aws_subnet" "subnet-4-private" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "10.10.3.0/24"
   availability_zone = "us-east-1d"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "private subnet4 1d"
  }
}
# resource "aws_key_pair" "terra-key" {
  # key_name   = "terra-key"
  # public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCZV2H4X97GZdTZC/5BTtxgj+h+EHmQoTKTVMkbbsDJQNXy9gfKGYwSOUA438hTeYYLuqfagpvRcRKBe/BBOK00FkuzzA8TJNw9Ach3e3gLjTT3Lo9QO5/3qGrRrswQfFH/+5fKNwGQvqQ4zkc8M33OS+kk62NI1JYZ0EmnKz21iuOlhO0oeM3c5fKzAZrex6U4CZYUiZuqdFdiNqW043XpVu1Ma3hWnT4haZNpVpSoGdxq25muFYtHVgS0ajZIOVlLL1OIil6ESjI9IjL5WhdXweuhAIP/u/vGZsFXtQoi5DUpEE7ohCHD7z/iFjV51ETp+MjQ3V8RYjyZRCe3qLRpNlSzrbCaoy4Ng6oZGGL+6FkBK2rwGrwBeTdYX0JFNEhwYOCpDNZ99NtQk0Hc6PdKYXQLQye2s7Kjtu4e1f7NTTgG9L+2+rNV3DhAd0/3Rukzin7RwClhEOh27SLXS743jTV1rjowie423pjwxnw4qtXw1iP/Ar4cpZeiWZKNsys= pnred@DESKTOP-N6MFM95"
# 
# }
# resource "aws_instance" "card-demo-instances" {
  # ami           = "ami-03a6eaae9938c858c"
  # instance_type = "t2.micro"
  # key_name = "terraform-key"
# 
  # tags = {
    # Name = "card-demo-instances"
  # }
# }

resource "aws_security_group" "allow_ssh-http" {
  name        = "allow_ssh-http"
  description = "Allow ssh and htpp inbound traffic"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

 egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }

}

# internet gateway for vpc---------------


resource "aws_internet_gateway" "card-igw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "card-igw"
  }
}
# rout table-----------------------------------
resource "aws_route_table" "card_rt_public" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.card-igw.id
  }

      
       tags = {
    Name = "card_rt_public"
  }
}
resource "aws_route_table" "card_rt_private" {
  vpc_id = aws_vpc.main-vpc.id

    tags = {
    Name = "card_rt_private"
  }
}
resource "aws_route_table_association" "card_public_sub1_rt_assoc" {
  subnet_id      = aws_subnet.subnet-1-public.id
  route_table_id = aws_route_table.card_rt_public.id
}

resource "aws_route_table_association" "card_public_sub2_rt_assoc" {
  subnet_id      = aws_subnet.subnet-2-public.id
  route_table_id = aws_route_table.card_rt_public.id
}

resource "aws_route_table_association" "card_private_sub3_rt_assoc" {
  subnet_id      = aws_subnet.subnet-3-private.id
  route_table_id = aws_route_table.card_rt_private.id
}
# target group--------------------
resource "aws_lb_target_group" "card_lb_tg" {
  name     = "card-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main-vpc.id
}
#  load balancer----------------------------
resource "aws_lb" "card_lb" {
  name             = "card-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_ssh-http.id]
  subnets            = [aws_subnet.subnet-1-public.id,aws_subnet.subnet-2-public.id]

          
  tags = {
    Environment = "production"
  }
}
# listner--------------------------------------------------
resource "aws_lb_listener" "card_website_listner" {
  load_balancer_arn = aws_lb.card_lb.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.card_lb_tg.arn
  }
}
#  launch templets---------------------------------------
resource "aws_launch_template" "LT-card-terraform" {
  name = "LT-card-terraform"
  image_id = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  key_name = "terraform-key"
  vpc_security_group_ids = [aws_security_group.allow_ssh-http.id]
  user_data = filebase64("bootstrap.sh")


  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "card-instance by terra"
    }
  }
}
# auto scaling group-----------------------------------
resource "aws_autoscaling_group" "card-asg" {
  vpc_zone_identifier = [aws_subnet.subnet-1-public.id,aws_subnet.subnet-2-public.id]
  desired_capacity   = 2
  max_size           = 5
  min_size           = 2
  name = "card-asg-terraform"
  target_group_arns = [aws_lb_target_group.card_lb_tg.arn]

  launch_template {
    id      = aws_launch_template.LT-card-terraform.id
    version = "$Latest"
  }
}





































