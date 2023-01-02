resource "aws_iam_role" "k8s_serviceaccount_aws_node" {
  name = "${var.name}-serviceaccount-aws-node"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.eks.id}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${aws_iam_openid_connect_provider.eks.url}:sub": "system:serviceaccount:kube-system:aws-node"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "k8s_serviceaccount_aws_node_cni" {
  role       = aws_iam_role.k8s_serviceaccount_aws_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

output "aws_iam_role_aws_k8s_serviceaccount_aws_node_arn" {
  value = aws_iam_role.k8s_serviceaccount_aws_node.arn
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  url             = aws_eks_cluster.default.identity[0].oidc[0].issuer
}