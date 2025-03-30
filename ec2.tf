/* hardcoded
resource "aws_instance" "public_instance" {
  ami           = "ami-xxxxxxxxxxxxxx"  # Replace with a valid AMI ID
  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnets[0]  # Place in a public subnet
  key_name      = "my-key-pair"  # Replace with your key pair name
  security_groups = [aws_security_group.public_sg.id]

  tags = {
    Name = "public-instance"
  }
}
*/

data "aws_caller_identity" "current" {}

locals {
  name_prefix = split("/", "${data.aws_caller_identity.current.arn}")[1]
}

#used by ec2 creation
data "aws_ami" "specific_al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.6.20250115.0-kernel-6.1-x86_64"] #find this version
  }
}

#assign access key, vpc, subnet and security group and ec level
resource "aws_instance" "my_instance" {
  ami                    = data.aws_ami.specific_al2023.id  # Use the dynamically fetched AMI
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.public_subnets[0]
  key_name               = "joseph-mod2key"
  security_groups        = [aws_security_group.public_sg.id]
  associate_public_ip_address = true  # This will assign a public IP to the instance

  tags = {
    Name = "${local.name_prefix}-2.7-al2023-instance"
  }

  # to mount EBS volume to ec2
  # use /dev/xvdh instead of /dev/sdh
  user_data = <<-EOF
            #!/bin/bash
            # Wait for volume to be attached
            until [ -e /dev/xvdh ]; do sleep 2; done
              
            # Check if filesystem exists
            if ! blkid /dev/xvdh; then
              mkfs -t ext4 /dev/xvdh
            fi
              
            mkdir -p /mnt/extra-storage
            mount /dev/xvdh /mnt/extra-storage
            echo '/dev/xvdh /mnt/extra-storage ext4 defaults 0 0' >> /etc/fstab
            EOF

}

# this is added in order to use
# ssh -i joseph-mod2key.pem ec2-user@$(terraform output -raw instance_public_ip)
# to test ec2 created
output "instance_public_ip" {
  value = aws_instance.my_instance.public_ip
}


