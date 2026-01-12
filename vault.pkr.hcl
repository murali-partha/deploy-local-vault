packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_name" {
  type    = string
  default = "vault-custom-ami-{{timestamp}}"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = var.ami_name
  instance_type = "t4g.micro"
  region        = "us-east-1"
  
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] 
  }
  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "file" {
    source      = "./vault"
    destination = "/tmp/vault"
  }

  provisioner "file" {
    source      = "./vault_config.hcl"
    destination = "/tmp/vault_config.hcl"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/vault /usr/local/bin/vault",
      "sudo chmod +x /usr/local/bin/vault",
      "sudo chown root:root /usr/local/bin/vault",
      "sudo mkdir -p /opt/vault/data",
      "sudo chown root:root /opt/vault/data",
      "sudo mv /tmp/vault_config.hcl /etc/vault_config.hcl",
    ]
  }

}