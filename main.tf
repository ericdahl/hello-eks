provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source        = "github.com/ericdahl/tf-vpc"
  admin_ip_cidr = var.admin_cidr

  tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  public_subnet_tags = {
    # To let K8S know to use these subnets for external load balancers
    "kubernetes.io/role/elb" = 1
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
      module.vpc.subnet_private1,
      module.vpc.subnet_private2,
      module.vpc.subnet_private3,
    ]
  }
  enabled_cluster_log_types = ["api", "audit"]

  depends_on = [aws_cloudwatch_log_group.control_plane]
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.default.name
  node_group_name = var.name
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids = [
    module.vpc.subnet_private1,
    module.vpc.subnet_private2,
    module.vpc.subnet_private3,
  ]
  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  remote_access {
    ec2_ssh_key               = aws_key_pair.default.key_name
    source_security_group_ids = [aws_security_group.jumphost.id]
  }
}
