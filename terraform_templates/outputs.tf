output "subnetIds" {
  value = [
    aws_subnet.public-subnet-01.id,
    aws_subnet.public-subnet-02.id,
    aws_subnet.private-subnet-01.id,
    aws_subnet.private-subnet-02.id
  ]
}

output "sg" {
  value = aws_security_group.eks-sg.id
}

output "vpcId" {
  value = aws_vpc.eks-vpc.id
}

output "eksId" {
  value = aws_eks_cluster.eks-cluster.id
}

output "instanceID" {
  value = aws_instance.eks-bastion-host.id
}

output "nodeGroupID" {
  value = aws_eks_node_group.eks-node-group
}
