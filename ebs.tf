# EBS - Elastic Block Store is under ec2 in aws console

data "aws_subnet" "selected" {
  id = module.vpc.public_subnets[0]  # Matches EC2's subnet
}

# 1GB EBS volume in the same AZ as ec2
resource "aws_ebs_volume" "extra_storage" {
  availability_zone = data.aws_subnet.selected.availability_zone  # Same AZ as EC2
  size              = 1  # 1GB
  type              = "gp3"  # General Purpose SSD (default)

  tags = {
    Name = "${local.name_prefix}-extra-volume"
  }

  depends_on = [aws_instance.my_instance]  # Explicit dependency
}

output "selected_subnet_az" {
  value = data.aws_subnet.selected.availability_zone
}

# Attach the Volume to the EC2 Instance**
resource "aws_volume_attachment" "ebs_attach" {
  # AWS Nitro hypervisor maps /dev/sdh to /dev/xvdh for NVMe volume
  # use /dev/xvdh instead of /dev/sdh
  device_name = "/dev/xvdh"  # Standard naming for additional volumes
  volume_id   = aws_ebs_volume.extra_storage.id
  instance_id = aws_instance.my_instance.id

  # Ensure the instance is running before attaching
  depends_on = [
    aws_instance.my_instance,
    aws_ebs_volume.extra_storage
  ]
}

