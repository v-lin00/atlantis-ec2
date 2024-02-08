output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.gitlab.public_ip
}
#The command above will provide the public IP address of the EC2 instance to the terminal after running terraform apply (For gitlab console)
