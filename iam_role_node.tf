resource "aws_iam_role" "node" {
  name = "${var.name}-node"

  assume_role_policy = <<POLICY
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
POLICY

}
resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_ssm_core" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.node.name
}

# Not ideal to attach this. Optimal setup is to create a dedicated IAM Role for CNI and
# link it to a k8s service account.
# Negatives:
#   - this setup allows pods to create ENIs themselves when they shouldn't have that permission (not least-priv)
# Positives:
#   - much simpler to deploy, particularly for this "hello world" demo
#   - does not have a complex dependency allowing for easier one-step deployment
#     - nodegroup depends on role, depends on service account, depends on k8s working depends on deploy
#     - alternative is 3 step: deploy cluster + role, deploy k8s service account, deploy nodegroup
#
# if neither of these options are implmented, result is:
#   NodeCreationFailure: Unhealthy nodes in the kubernetes cluster.
#
# See more at:
# https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html
# https://aws.github.io/aws-eks-best-practices/security/docs/iam/#update-the-aws-node-daemonset-to-use-irsa
resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}