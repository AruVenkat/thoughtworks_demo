resource "aws_security_group" "eks-bastion-sg" {
  name        = "eks-bastion-sg"
  vpc_id      = aws_vpc.eks-vpc.id
  description = "Cluster communication with worked nodes"
  ingress {
    description = "TLS from VPC"
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

resource "aws_instance" "eks-bastion-host" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.eks-bastion-sg.id]
  subnet_id              = aws_subnet.public-subnet-01.id
  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = true
  }
  user_data            = "${file("install_kubectl.sh")}"
  iam_instance_profile = "eks-admin"
  tags = {
    "Name" = "eks-bastion-instance"
  }
  volume_tags = {
    "Name" = "eks-bastion-volume"
  }
}