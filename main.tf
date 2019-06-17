provider "aws" {
  region = "us-east-1"
}

// Look up the pre-created Lab VPC using the "filter" block
data "aws_vpc" "lab_vpc" {
  filter {
    name   = "tag:Name"
    values = ["TerraformLabVpc"]
  }
}

data "aws_subnet" "lab_default_subnet" {
  filter {
    name   = "tag:Name"
    values = ["TerraformLabDefaultSubnet"]
  }
}

// Create a new security group
resource "aws_security_group" "windows_server_rdp" {
    name_prefix = "${var.lab_username}-"
    description = "Allow RDP connections to windows server."
    vpc_id      = data.aws_vpc.lab_vpc.id

    ingress {
      from_port   = "22"
      to_port     = "22"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port   = "80"
      to_port     = "80"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      User = "${var.lab_username}"
    }
}

resource "tls_private_key" "provisioning_key" {
  algorithm   = "RSA"
  rsa_bits    = 2048
}

resource "aws_key_pair" "aws_provisioning_pair" {
  key_name_prefix = "${var.lab_username}"
  public_key      = "${tls_private_key.provisioning_key.public_key_openssh}"
}

resource "aws_instance" "private_module_instance" {
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.aws_provisioning_pair.key_name}"

  // Creation of this instance depends on the instance profile already existing
  associate_public_ip_address = true

  // Creation of this instance depends on the security group already existing
  vpc_security_group_ids      = ["${aws_security_group.windows_server_rdp.id}"]
  subnet_id                   = data.aws_subnet.lab_default_subnet.id

  tags = {
      Name        = "Module 3 Lab 4"
      User        = "${var.lab_username}"
      Version     = "${var.env_version}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "echo '${var.filecontent}' | sudo tee /var/www/html/index.html",
      "sudo service nginx start"
    ]

    connection {
      host        = "${aws_instance.private_module_instance.public_ip}"
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${tls_private_key.provisioning_key.private_key_pem}"
    }
  }
}
