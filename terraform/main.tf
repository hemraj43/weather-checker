# This is where you put your resource declaration
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_pair_name
  public_key = var.public_key
}

resource "aws_security_group" "sg" {
  name = var.sg_name
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = "0"
    to_port     = "0"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = "5000"
    to_port     = "5000"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "ssh"
    from_port   = "22"
    to_port     = "22"
  }
}

resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = var.key_pair_name
  security_groups             = [aws_security_group.sg.id]
  depends_on                  = [aws_key_pair.key_pair]
  # copy all templates and python files to ec2 instance
  provisioner "file" {
    source      = "../templates"
    destination = "/app/templates"
  }
  provisioner "file" {
    source      = "main.py"
    destination = "/app/"
  }
  provisioner "file" {
    source      = "requirements.txt"
    destination = "/app/"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = aws_key_pair.key_pair
      host        = self.public_ip

    }
    inline = [
      "sudo mkdir -p /app",
      "sudo apt install python-pip",
      "cd /app",
      "pip install --no-cache-dir -r requirements.txt",
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
