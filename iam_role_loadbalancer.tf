#resource "aws_iam_role" "aws_load_balancer_controller" {
#  name = "${var.name}-aws-load-balancer-controller"
#
#  assume_role_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Effect": "Allow",
#      "Principal": {
#        "Federated": "${aws_iam_openid_connect_provider.eks.id}"
#      },
#      "Action": "sts:AssumeRoleWithWebIdentity",
#      "Condition": {
#        "StringEquals": {
#          "${aws_iam_openid_connect_provider.eks.url}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
#        }
#      }
#    }
#  ]
#}
#EOF
#}
#
#resource "aws_iam_policy" "aws_load_balancer_controller" {
#  name   = "${var.name}-aws-load-balancer-controller"
#  policy = file("templates/iam/policy/k8s-load-balancer.json")
#}
#
#resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
#  role       = aws_iam_role.aws_load_balancer_controller.name
#  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
#}