data "kubernetes_service_account" "aws_node" {
  metadata {
    name      = "aws-node"
    namespace = "kube-system"
  }
}

resource "kubernetes_annotations" "aws_node_role" {

  kind = "ServiceAccount"

  api_version = "v1"

  metadata {
    name      = "aws-node"
    namespace = "kube-system"
  }

  annotations = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.k8s_serviceaccount_aws_node.arn
  }
}

#resource "kubernetes_service_account" "example" {
#
#
#
#  metadata {
#    namespace = "kube-system"
#    name = "aws-node"
#
#    annotations = {
#
#      # kubectl annotate serviceaccount -n kube-system aws-node eks.amazonaws.com/role-arn=$(terraform output aws_iam_role_aws_k8s_serviceaccount_aws_node_arn | tr -d '"')
#      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eksctl-eks-cluster-nodegroup-ng-NodeInstanceRole-1KQZQZQZQZQZQ"
#    }
#  }
#
#
#}