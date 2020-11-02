resource "aws_iam_role" "eks-node-group-role" {
  name = "${aws_eks_cluster.eks-cluster.name}-eks-node-group-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "eks-aws-ebs-policy" {
  name        = "Amazon_EBS_CSI_Driver"
  description = "Policy for enabling EBS access to nodes"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteSnapshot",
        "ec2:DeleteTags",
        "ec2:DeleteVolume",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks-attach-ebs-csi-driver-policy" {
  role       = aws_iam_role.eks-node-group-role.name
  policy_arn = aws_iam_policy.eks-aws-ebs-policy.arn
}

resource "aws_iam_role_policy_attachment" "eks-attach-worker-node-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node-group-role.name
}

resource "aws_iam_role_policy_attachment" "eks-attach-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node-group-role.name
}

resource "aws_iam_role_policy_attachment" "eks-attach-ecr-read-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node-group-role.name
}

resource "aws_eks_node_group" "eks-node-group" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "${aws_eks_cluster.eks-cluster.name}-node-group"
  node_role_arn   = aws_iam_role.eks-node-group-role.arn
  subnet_ids = [
    aws_subnet.private-subnet-01.id,
    aws_subnet.private-subnet-02.id
  ]
  scaling_config {
    desired_size = 3
    max_size     = 6
    min_size     = 3
  }
  disk_size = 512
  instance_types = [
    "t3.medium"
  ]
  depends_on = [
    aws_iam_role_policy_attachment.eks-attach-worker-node-policy,
    aws_iam_role_policy_attachment.eks-attach-cni-policy,
    aws_iam_role_policy_attachment.eks-attach-ecr-read-policy
  ]
}

