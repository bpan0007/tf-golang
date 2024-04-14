


data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "ssh-https" {
    name        = "ssh-https"
    vpc_id = module.vpc.vpc_id

    description = "Allow SSH and HTTPS inbound traffic"
    ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
}

resource "aws_instance" "kind" {
    ami           = data.aws_ami.ubuntu.id
    subnet_id              = element(module.vpc.public_subnets, 2)
    instance_type = "t2.micro"
    key_name      = "kind-key-pair"
    vpc_security_group_ids = [aws_security_group.ssh-https.id] 
    user_data = <<-EOF
              #!/bin/bash
              set -euxo pipefail

              # Update and install necessary packages
              yum update -y
              yum install -y docker git
              systemctl start docker
              systemctl enable docker

              # Install kubectl
              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

              # Install Kind
              curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.11.1/kind-$(uname)-amd64"
              chmod +x ./kind
              mv ./kind /usr/local/bin/kind

              # Create a Kind Kubernetes cluster
              kind create cluster
              EOF


    tags = {
        Name = "kind-instance"
    }
}
