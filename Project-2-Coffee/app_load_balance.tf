### !!! Read Me First !!! ###
# This project is for display purposes only #
# This file is designed only as a representation of the architecture used #
### !!! Thank You !!! ###

# Create a security group for the ALB
resource "aws_security_group" "alb_sg" {
  name        = "coffee_alb_sg"
  description = "ALB security group"

  vpc_id = aws_vpc.main.id

  # Allow incoming HTTP and HTTPS traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["x.x.x.x/x"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["x.x.x.x/x"]
  }

  # Allow outgoing traffic to the web servers
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "-1"
    cidr_blocks = ["x.x.x.x/x"] # Subnet CIDR blocks
  }
}

# Create an Application Load Balancer (ALB)
resource "aws_lb" "alb" {
  name               = "coffee-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}

# Create a target group for the ALB
resource "aws_lb_target_group" "target_group" {
  name        = "coffee-web-target-group"
  port        = 443
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTPS"
    matcher             = "200-299"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

# Output the ALB DNS name
output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
