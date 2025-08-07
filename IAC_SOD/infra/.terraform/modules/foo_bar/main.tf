resource "aws_launch_template" "rhoro_lt" {
  name_prefix   = "rhoro-foo-${var.name_suffix}"
  image_id      = "ami-020cba7c55df1f615"
  instance_type = "t3.micro"
  key_name = var.key_name
  vpc_security_group_ids = [var.sg_id]

  lifecycle {
    create_before_destroy = true
  }

  user_data = base64encode(<<EOF
#!/bin/bash
apt update -y
apt install nginx -y
mkdir -p /var/www/html${var.nginx_path}
echo "<h1>${var.nginx_text}</h1>" > /var/www/html${var.nginx_path}/index.html
systemctl enable nginx
systemctl start nginx
EOF
  )

  tags = merge(var.tags, {
    Name = "rhoro-lt-${var.name_suffix}"
  })
}

resource "aws_autoscaling_group" "rhoro_asg" {
  launch_template {
    id      = aws_launch_template.rhoro_lt.id
    version = "$Latest"
  }
  
  min_size           = 1
  max_size           = 1
  desired_capacity   = 1
  vpc_zone_identifier = [var.subnet_id]
  target_group_arns   = [var.target_group_arn]
  
  tag {
  key                 = "Name"
  value               = "rhoro-${var.name_suffix}"
  propagate_at_launch = true
}

tag {
  key                 = "Terraform"
  value               = "true"
  propagate_at_launch = true
}

tag {
  key                 = "Owner"
  value               = "rareshoro"
  propagate_at_launch = true
}

tag {
  key                 = "Email"
  value               = "rares.horodinca@endava.com"
  propagate_at_launch = true
}
  
}
    
