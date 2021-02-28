resource "aws_security_group" "demo_node" {
  name        = "terraform-eks-demo-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                                      = "terraform-eks-demo-node"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "demo_node_ingress_self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.demo_node.id
  source_security_group_id = aws_security_group.demo_node.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "demo_node_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.demo_node.id
  source_security_group_id = aws_security_group.cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "demo_cluster_ingress_node_https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.demo_node.id
  to_port                  = 443
  type                     = "ingress"
}

data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-v*"]
  }

  filter {
    name   = "description"
    values = ["*AmazonLinux2*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon Account ID
}

# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_region" "current" {
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  demo-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.cluster.certificate_authority[0].data}' '${var.cluster_name}'
USERDATA

}

resource "aws_launch_configuration" "worker_m4_large" {
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.node.name
  image_id                    = data.aws_ami.eks_worker.id
  instance_type               = "m4.large"
  name_prefix                 = "worker_m4_large"

  spot_price = ".1"

  security_groups = [
    aws_security_group.cluster.id,
    module.vpc.sg_allow_22,
    module.vpc.sg_allow_egress,
  ]

  user_data_base64 = base64encode(local.demo-node-userdata)

  key_name = aws_key_pair.default.key_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "worker_m4_large" {
  launch_configuration = aws_launch_configuration.worker_m4_large.id

  min_size         = 1
  desired_capacity = 3
  max_size         = 10
  name             = "worker_m4_large"

  vpc_zone_identifier = [
    module.vpc.subnet_private1,
    module.vpc.subnet_private2,
    module.vpc.subnet_private3,
  ]

  tag {
    key                 = "Name"
    value               = "terraform-eks-demo"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "enabled"
    propagate_at_launch = false
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${aws_eks_cluster.cluster.name}"
    value               = "enabled"
    propagate_at_launch = false
  }
}

resource "aws_launch_configuration" "worker_m4_2xlarge" {
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.node.name
  image_id                    = data.aws_ami.eks_worker.id
  instance_type               = "m4.2xlarge"
  name_prefix                 = "worker_m4_2xlarge"

  spot_price = ".4"

  security_groups = [
    aws_security_group.cluster.id,
    module.vpc.sg_allow_22,
    module.vpc.sg_allow_egress,
  ]

  user_data_base64 = base64encode(local.demo-node-userdata)

  key_name = aws_key_pair.default.key_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "worker_m4_2xlarge" {
  launch_configuration = aws_launch_configuration.worker_m4_2xlarge.id

  min_size         = 1
  desired_capacity = 2
  max_size         = 10
  name             = "worker_m4_2xlarge"

  vpc_zone_identifier = [
    module.vpc.subnet_private1,
    module.vpc.subnet_private2,
    module.vpc.subnet_private3,
  ]

  tag {
    key                 = "Name"
    value               = "terraform-eks-demo"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "enabled"
    propagate_at_launch = false
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${aws_eks_cluster.cluster.name}"
    value               = "enabled"
    propagate_at_launch = false
  }
}

