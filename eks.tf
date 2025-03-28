resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_eks_cluster" "stoic_eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_role.arn
  vpc_config {
    subnet_ids = concat(aws_subnet.pub_sub[*].id, aws_subnet.pri_sub[*].id)
  }
}

resource "aws_iam_role" "node_role" {
  name = "eks-node-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_eks_node_group" "Dev-node-group" {
  cluster_name   = aws_eks_cluster.stoic_eks_cluster.name
  node_role_arn  = aws_iam_role.node_role.arn
  subnet_ids     = aws_subnet.pri_sub[*].id
  instance_types = [var.dev_instance_type]
  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }
}

resource "aws_eks_node_group" "Prod-node-group" {
  cluster_name   = aws_eks_cluster.stoic_eks_cluster.name
  node_role_arn  = aws_iam_role.node_role.arn
  subnet_ids     = aws_subnet.pri_sub[*].id
  instance_types = [var.prod_instance_type]
  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }
}

output "vpc_id" {
  value = aws_vpc.stoic_eks_vpc.id
}

output "eks_cluster_id" {
  value = aws_eks_cluster.stoic_eks_cluster.id
}

output "endpoint" {
  value = aws_eks_cluster.stoic_eks_cluster.endpoint
}
