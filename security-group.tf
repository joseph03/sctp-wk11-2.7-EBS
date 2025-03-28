# Add this data source to fetch my current public IP
data "http" "my_ip" {
  url = "https://ifconfig.me/ip"
}

output "my_ip_all" {
 value = data.http.my_ip
}

output "my_ip" {
  value = "${chomp(data.http.my_ip.body)}/32"
}

resource "aws_security_group" "public_sg" {
  name        = "public-sg"
  description = "Allow SSH and HTTPS inbound"
  vpc_id      = module.vpc.vpc_id  # Attach to the VPC

  # Inbound rules
  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from any IPv4
    cidr_blocks = ["${chomp(data.http.my_ip.body)}/32"]  # Dynamically fetch my IP
    #ipv6_cidr_blocks = ["::/0"]  # Allow SSH from any IPv6
  }

  ingress {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  # Outbound rule (Allow all traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from any IPv4
    #ipv6_cidr_blocks = ["::/0"]  # Allow HTTP from any IPv6
  }

  tags = {
    Name = "public-security-group"
  }
}
