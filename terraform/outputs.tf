# This is where you put your outputs declaration

output "instance_public_ip" {
  value = aws_instance.ec2.associate_public_ip_address
}