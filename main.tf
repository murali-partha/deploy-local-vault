provider "aws" {
  region = "us-east-1" # Change to your preferred region
}

data "aws_ami" "vault_ami" {
  most_recent = true
  owners      = ["self"] 
  filter {
    name   = "name"
    values = ["vault-custom-ami-*"] 
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "tls_private_key" "vault_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_key_pair" "generated_key" {
  key_name   = "vault-server-key"
  public_key = tls_private_key.vault_key.public_key_openssh
}


resource "local_file" "private_key" {
  content         = tls_private_key.vault_key.private_key_pem
  filename        = "${path.module}/vault-key.pem"
  file_permission = "0400" 
}

resource "aws_security_group" "vault_sg" {
  name        = "vault-sg"
  description = "Allow Vault and SSH traffic"

  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vault_server" {
  instance_type = "t4g.micro"
  ami = data.aws_ami.vault_ami.id
  key_name      = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.vault_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "${var.VAULT_LICENSE}" >> /opt/vault/license.hclic
              sudo vault server -config=/etc/vault_config.hcl > vault.log &
              EOF

  tags = {
    Name = "HashiCorp-Vault-Server"
  }
}

output "vault_public_ip" {
  value = aws_instance.vault_server.public_ip
}