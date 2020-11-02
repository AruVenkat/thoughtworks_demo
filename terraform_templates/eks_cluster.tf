resource "aws_iam_role" "eks-cluster-role" {
  name               = "eks-cluster-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "attach-eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "attach-eks-service-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

resource "aws_eks_cluster" "eks-cluster" {
  name     = var.eks-cluster-name
  version  = "1.16"
  role_arn = aws_iam_role.eks-cluster-role.arn
  vpc_config {
    subnet_ids = [
      aws_subnet.public-subnet-01.id,
      aws_subnet.public-subnet-02.id,
      aws_subnet.private-subnet-01.id,
      aws_subnet.private-subnet-02.id
    ]
    security_group_ids = [
      aws_security_group.eks-sg.id
    ]
    endpoint_private_access = true
    endpoint_public_access  = false
  }
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
  depends_on = [
    aws_iam_role_policy_attachment.attach-eks-cluster-policy,
    aws_iam_role_policy_attachment.attach-eks-service-policy,
    aws_cloudwatch_log_group.eks-log-group
  ]
}

resource "aws_cloudwatch_log_group" "eks-log-group" {
  name              = "/aws/eks/${var.eks-cluster-name}/cluster"
  retention_in_days = 30
}
