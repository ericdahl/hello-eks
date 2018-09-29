output "kubeconfig" {
  value = "${local.kubeconfig}"
}

output "aws_instance.jumphost.public_ip" {
  value = "${aws_instance.jumphost.public_ip}"
}
