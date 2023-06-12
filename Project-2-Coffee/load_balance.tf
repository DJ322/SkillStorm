### !!! Read Me First !!! ###
# This project is for display purposes only #
# This file is designed only as a representation of the architecture used #
### !!! Thank You !!! ###

# Security group for the ALB
resource "aws_security_group" "alb_sg" {
  name        = "coffee_alb_sg"
  description = "ALB security group"

  vpc_id = aws_vpc.main.id

  # Allow incoming HTTP and HTTPS traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outgoing traffic to the web servers
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Subnet CIDR blocks
  }
}

# Application Load Balancer (ALB) for public subnet east 1a & east 1b
resource "aws_lb" "alb" {
  name               = "coffee-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.pub_sbnet_nat_1a.id, aws_subnet.pub_sbnet_nat_1b.id]
}

# Target group for the load balancer on port 80
resource "aws_lb_target_group" "target_group" {
  name        = "coffee-web-target-group"
  port        = 80
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
# Listener port 80 to app load balancer
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

# This outputs the alb DNS name
output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
