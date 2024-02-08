resource "aws_instance" "gitlab" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  security_groups             = [aws_security_group.gitlab_sg.name]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update && sudo apt upgrade -y
              sudo apt-get install -y curl openssh-server ca-certificates
              PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
              sudo EXTERNAL_URL="http://${PUBLIC_IP}" apt-get install gitlab-ee
              EOF

  tags = {
    Name = "GitLab"
  }
}
