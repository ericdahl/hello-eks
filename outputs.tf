#//output "kubeconfig" {
#//  value = local.kubeconfig
#//}
#
#output "aws_instance_jumphost_public_ip" {
#  value = aws_instance.jumphost.public_ip
#}

#output "eks_admin_token" {
#  value = data.kubernetes_secret.eks_admin.data.token
#}