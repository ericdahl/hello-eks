provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source        = "github.com/ericdahl/tf-vpc"
  admin_ip_cidr = "${var.admin_cidr}"

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_eks_cluster" "cluster" {
  name     = "${var.cluster_name}"
  role_arn = "${aws_iam_role.cluster.arn}"

  vpc_config {
    subnet_ids = [
      "${module.vpc.subnet_private1}",
      "${module.vpc.subnet_private2}",
      "${module.vpc.subnet_private3}",
    ]

    security_group_ids = [
      "${module.vpc.sg_allow_egress}",
      "${aws_security_group.cluster.id}",
    ]
  }
}

resource "aws_security_group" "cluster" {
  vpc_id      = "${module.vpc.vpc_id}"
  name        = "${var.cluster_name}_cluster"
  description = "Allows communication between k8s nodes"
}

resource "aws_security_group_rule" "cluster_0" {
  security_group_id = "${aws_security_group.cluster.id}"

  type      = "ingress"
  protocol  = "all"
  from_port = 0
  to_port   = 0

  //  source_security_group_id = "${aws_security_group.cluster.id}"
  self = true
}
