# This is where you put your resource declaration
data "aws_region" "current" {}
data "aws_vpc" "vpc" {
  id = var.vpc_id
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_pair_name
  public_key = var.public_key
}

resource "aws_security_group" "sg" {
  name        = var.sg_name
  vpc_id      = data.aws_vpc.vpc.id
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "-1"
    from_port = "0"
    to_port = "0"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
    from_port = "5000"
    to_port = "5000"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "ssh"
    from_port = "22"
    to_port = "22"
  }
}

resource "aws_instance" "ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = var.key_pair_name
  security_groups             = [aws_security_group.sg.id]

  provisioner "file" {
    source      = "../templates"
    destination = "/app/templates"
  }
  provisioner "file" {
    source      = "main.py"
    destination = "/app/"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /app",
      "sudo apt install pip",
      "pip install requests diskcache flask gunicorn",
      "gunicorn -w 1 -b 0.0.0.0:5000 main:app"
    ]
  }


  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = aws_key_pair.key_pair
    host        = self.public_ip

  }
}
