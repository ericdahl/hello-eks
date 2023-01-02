resource "aws_iam_role" "cluster" {
  name = "${var.name}-cluster"

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

resource "aws_iam_role_policy_attachment" "cluster_managed_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}
#
#//resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSServicePolicy" {
#//  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
#//  role       = aws_iam_role.cluster.name
#//}
#//
#////
#//// Worker Node
#////
#//

#

#
#
## TODO: hack
##  NodeCreationFailure: Unhealthy nodes in the kubernetes cluster.
## https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html
#resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
#  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#  role       = aws_iam_role.node.name
#}
#

#//
#//resource "aws_iam_instance_profile" "node" {
#//  name = "${var.cluster_name}_node"
#//  role = aws_iam_role.node.name
#//}
#//
#//resource "aws_iam_policy" "cluster_autoscale" {
#//  name = "cluster_autoscale"
#//
#//  policy = <<EOF
#//{
#//    "Version": "2012-10-17",
#//    "Statement": [
#//        {
#//            "Effect": "Allow",
#//            "Action": [
#//                "autoscaling:DescribeAutoScalingGroups",
#//                "autoscaling:DescribeAutoScalingInstances",
#//                "autoscaling:DescribeTags",
#//                "autoscaling:SetDesiredCapacity",
#//                "autoscaling:TerminateInstanceInAutoScalingGroup"
#//            ],
#//            "Resource": "*"
#//        }
#//    ]
#//}
#//EOF
#//
#//}
#//
#//# TODO: identify how to remove this and attach only to cluster-autoscaler deployment pods
#//resource "aws_iam_role_policy_attachment" "node_cluster_autoscale" {
#//  policy_arn = aws_iam_policy.cluster_autoscale.arn
#//  role       = aws_iam_role.node.name
#//}
#//
#
#
#
#
#resource "aws_iam_openid_connect_provider" "eks" {
#  client_id_list  = ["sts.amazonaws.com"]
#  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
#  url             = aws_eks_cluster.default.identity[0].oidc[0].issuer
#}
#
#
