### !!! Read Me First !!! ###
# This project is for display purposes only #
# This file is designed only as a representation of the architecture used #
### !!! Thank You !!! ###

# Create an Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "asg" {
  name                = "coffee-web-asg"
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2
  vpc_zone_identifier = [aws_subnet.pvt_sbnet_ec2_1a.id, aws_subnet.pvt_sbnet_ec2_1b.id]
  target_group_arns   = [aws_lb_target_group.target_group.arn]
  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }
}

# EC2 Launch Template with user data
# Create a launch template for the web servers
resource "aws_launch_template" "web_lt" {
  name          = "coffee-web-lt"
  image_id      = "ami-053b0d53c279acc90" # Ubtuntu AMI for wordpress
  instance_type = "t3.medium"             # Small Load usage
  iam_instance_profile {
    name = "SSM"
  }
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data = base64encode(<<EOF
#!/bin/bash  
apt-get update   
apt-get install -y apache2 mysql-client php php-mysql libapache2-mod-php php-cli php-curl php-gd php-mbstring php-xml php-xmlrpc
cd /var/www/html/
wget -c https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
rm latest.tar.gz
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/wordpress
cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
sed -i "s/database_name_here/wordpress/g" /var/www/html/wordpress/wp-config.php
sed -i "s/username_here/admin/g" /var/www/html/wordpress/wp-config.php
sed -i "s/password_here/12345678/g" /var/www/html/wordpress/wp-config.php
sed -i "s/localhost/${aws_rds_cluster.rds_cluster.endpoint}/g" /var/www/html/wordpress/wp-config.php
systemctl restart apache2
EOF
  depends_on = [aws_nat_gateway.nat_gateway]
}

# Security Goup chaining for high security
# Security group for the web servers
resource "aws_security_group" "web_sg" {
  name        = "coffee_web_sg"
  description = "Web server security group"

  vpc_id = aws_vpc.main.id

  # Incoming HTTPS traffic rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["x.x.x.x/x"] # Replace with the CIDR block of the RDS database subnet
  }

#######  Caution #######  Caution #######  Caution ####### 
# The databse is currently set to "wide open" # 
# These must be changed to MySQL port number and subnets only # 
#######  Caution #######  Caution #######  Caution ####### 
  
  # Outgoing traffic to the RDS database rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # MySQL Protocal 
    cidr_blocks = ["0.0.0.0/0"] # Replace with the CIDR block of the RDS database subnet
  }
}
