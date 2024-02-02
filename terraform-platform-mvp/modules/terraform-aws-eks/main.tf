

# tfsec:ignore:aws-eks-enable-control-plane-logging
# tfsec:ignore:aws-eks-encrypt-secrets
# tfsec:ignore:aws-eks-no-public-cluster-access-to-cidr
# tfsec:ignore:aws-eks-no-public-cluster-access
resource "aws_eks_cluster" "self" {
  name     = var.name_prefix
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids             = var.subnet_ids
    endpoint_public_access = true
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_role_policy_attachment]
}

resource "aws_eks_node_group" "self" {
  cluster_name    = aws_eks_cluster.self.name
  node_group_name = "${var.name_prefix}-node-group"
  node_role_arn   = aws_iam_role.managed_node_role.arn
  subnet_ids      = var.subnet_ids
  instance_types  = var.instance_types
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  depends_on = [
    aws_iam_role_policy_attachment.managed_node_amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.managed_node_amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.managed_node_amazon_ec2_container_registry_read_only,
  ]
}

resource "aws_iam_role" "eks_cluster_role" {
  name               = "${var.name_prefix}-role"
  assume_role_policy = <<EOF
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
EOF
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "managed_node_role" {
  name               = "${var.name_prefix}-managed-node-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "managed_node_amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.managed_node_role.name
}

resource "aws_iam_role_policy_attachment" "managed_node_amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.managed_node_role.name
}

resource "aws_iam_role_policy_attachment" "managed_node_amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.managed_node_role.name
}

resource "aws_security_group_rule" "cluster_worker_ingress" {
  type                     = "ingress"
  security_group_id        = aws_security_group.cluster_worker_sg.id
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_eks_cluster.self.vpc_config[0].cluster_security_group_id
  description              = "Allow ingress traffic between cluster and worker nodes"

}

resource "aws_security_group_rule" "cluster_worker_egress" {
  type                     = "egress"
  security_group_id        = aws_security_group.cluster_worker_sg.id
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_eks_cluster.self.vpc_config[0].cluster_security_group_id
  description              = "Allow egress traffic between cluster and worker nodes"
}

resource "aws_security_group" "cluster_worker_sg" {
  name        = "${var.name_prefix}-cluster-worker-sg"
  description = "Security group for allowing 443 for worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    self        = true
    description = "Allow 443 ingress traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all egress traffic"
  }
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.self.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.self.identity[0].oidc[0].issuer
}


# tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "eks_cluster_autoscaler_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_cluster_autoscaler" {
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_autoscaler_assume_role_policy.json
  name               = "eks-cluster-autoscaler"
}

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "eks_cluster_autoscaler" {
  name = "eks-cluster-autoscaler"

  policy = jsonencode({
    Statement = [{
      Action = [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_autoscaler_attach" {
  role       = aws_iam_role.eks_cluster_autoscaler.name
  policy_arn = aws_iam_policy.eks_cluster_autoscaler.arn
}