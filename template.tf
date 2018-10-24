# Provider declaration

provider "aws" {
  region = "eu-west-1"
}
variable "server_port" {
  description = "Port used for HTTP request"
  default = 8080
}
variable "ami" {
  description = "standard AMI"
  default = "ami-02c792a8fad63874f"
}
resource "aws_instance" "example_instance" {
  ami = "${var.ami}"
  instance_type = "t2.micro"
  tags {
      Name = "MyInstance"
      Owner = "GSS"
      Version = 2
  }
  vpc_security_group_ids = ["${aws_security_group.example_instance.id}"]
  user_data = <<-EOF
            #!/bin/bash
            echo "Hello, World" > index.html
            nohup busybox httpd -f -p "${var.server_port}" &
            EOF
}
resource "aws_security_group" "example_instance" {
    name = "terraform_example_instance"
    ingress {
        from_port = "${var.server_port}"
        to_port = "${var.server_port}"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    description = "Managed by Karol"
    lifecycle {
        create_before_destroy = true
    }
}
output "public_ip" {
  value = "${aws_instance.example_instance.public_ip}"
}
# Auto Scaling GroupConfiguration

resource "aws_launch_configuration" "asg_lc" {
  image_id = "${var.ami}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.example_instance.id}"]
  lifecycle {
      create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "asg" {
  launch_configuration = "${aws_launch_configuration.asg_lc.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  metrics_granularity = 5
  min_size = 2
  max_size = 3
  tag {
      key = "Name"
      value = "Managed by Terraform"
      propagate_at_launch = true
  }
}


# Data sources

data "aws_availability_zones" "all" {
  
}






