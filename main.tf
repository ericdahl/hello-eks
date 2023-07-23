provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Name       = "hello-eks"
      Repository = "https://github.com/ericdahl/hello-eks"
    }
  }
}

resource "aws_cloudwatch_log_group" "control_plane" {
  name              = "/aws/eks/${var.name}/cluster"
  retention_in_days = 7
}

resource "aws_eks_cluster" "default" {
  name     = var.name
  role_arn = aws_iam_role.cluster.arn
  vpc_config {
    subnet_ids = [
      # using public subnets to save money on NAT gateways and simplicity; not recommended for production
      aws_subnet.public["us-east-1a"].id,
      aws_subnet.public["us-east-1b"].id,
      aws_subnet.public["us-east-1c"].id,
    ]
  }
  enabled_cluster_log_types = ["api", "audit"]

  depends_on = [
    aws_iam_role_policy_attachment.cluster_managed_policy,
    aws_cloudwatch_log_group.control_plane,
  ]
}


resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.default.name
  node_group_name = var.name
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids = [
    # using public subnets to save money on NAT gateways and simplicity; not recommended for production
    aws_subnet.public["us-east-1a"].id,
    aws_subnet.public["us-east-1b"].id,
    aws_subnet.public["us-east-1c"].id,
  ]
  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  #  depends_on = [
  #    kubernetes_annotations.aws_node_role
  #  ]

  #  remote_access {
  #    ec2_ssh_key               = aws_key_pair.default.key_name
  #    source_security_group_ids = [aws_security_group.jumphost.id]
  #  }
}
