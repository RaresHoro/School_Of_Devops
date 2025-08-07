provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  name = "rhoro-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/28", "10.0.2.0/28"]
  public_subnets  = ["10.0.101.0/28", "10.0.102.0/28"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false


  tags = {
    Terraform = "true"
    Owner     = "rareshoro"
    Email = "rares.horodinca@endava.com"
  }
}

data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  my_ip_cidr = "${chomp(data.http.my_ip.response_body)}/32"

  common_tags = {
    Terraform = "true"
    Owner     = "rareshoro"
    Email     = "rares.horodinca@endava.com"
  }
}

resource "aws_security_group" "rhoro_sg_bastion" {
  name        = "rhoro-sg-bastion"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = merge(local.common_tags, {
        Name = "rhoro-sg-bastion"
    })
}

resource "aws_security_group" "rhoro_sg_alb" {
  name        = "rhoro-sg-alb"
  description = "Allow HTTP from anywhere"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = merge(local.common_tags, {
        Name = "rhoro-sg-alb"
    })
}


resource "aws_security_group" "rhoro_sg_web" {
  name        = "rhoro-sg-web"
  description = "Allow load balancer inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from LB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [ aws_security_group.rhoro_sg_alb.id ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = merge(local.common_tags, {
        Name = "rhoro-sg-alb"
    })
}

resource "aws_instance" "bastion" {
  ami           = "ami-020cba7c55df1f615" 
  instance_type = "t3.micro"
  key_name      = var.key_name
  subnet_id     = module.vpc.public_subnets[0]
  vpc_security_group_ids = [ aws_security_group.rhoro_sg_bastion.id ]

  associate_public_ip_address = true
  tags = merge(local.common_tags, {
    Name = "rhoro-bastion"
  })
}

output "rhoro_bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

module "rhoro_asg_foo" {
  source = "./.terraform/modules/foo_bar"

  name_suffix        = "foo"
  key_name           = var.key_name
  subnet_id          = module.vpc.private_subnets[0]
  sg_id              = aws_security_group.rhoro_sg_web.id
  target_group_arn   = aws_lb_target_group.foo.arn
  nginx_text         = "Foo"
  nginx_path         = "/foo"
  tags               = local.common_tags
}

module "rhoro_asg_bar" {
  source = "./.terraform/modules/foo_bar"

  name_suffix        = "bar"
  key_name           = var.key_name
  subnet_id          = module.vpc.private_subnets[1]
  sg_id              = aws_security_group.rhoro_sg_web.id
  target_group_arn   = aws_lb_target_group.bar.arn
  nginx_text         = "Bar"
  nginx_path         = "/bar"
  tags               = local.common_tags
}

resource "aws_lb" "rhoro_alb" {
  name               = "rhoro-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.rhoro_sg_alb.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = merge(local.common_tags, {
    Name = "rhoro-alb"
  })
}

resource "aws_lb_target_group" "foo" {
  name     = "rhoro-foo"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name = "rhoro-group-foo"
  })
}

resource "aws_lb_target_group" "bar" {
  name     = "rhoro-bar"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name = "rhoro-group-bar"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.rhoro_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.bar.arn
  }

  tags = merge(local.common_tags, {
    Name = "rhoro-alb-listener"
  })
}

resource "aws_lb_listener_rule" "foo" {
  listener_arn = aws_lb_listener.http.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.foo.arn
  }
  condition {
    path_pattern {
      values = ["/foo*"]
    }
  }

  tags = merge(local.common_tags, {
    Name = "rhoro-rule-foo"
  })
}
resource "aws_lb_listener_rule" "bar" {
  listener_arn = aws_lb_listener.http.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bar.arn
  }
  condition {
    path_pattern {
      values = ["/bar*"]
    }
  }

  tags = merge(local.common_tags, {
    Name = "rhoro-rule-bar"
  })
}


output "rhoro_alb_dns_name" {
  value = aws_lb.rhoro_alb.dns_name
}