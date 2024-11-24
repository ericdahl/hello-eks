data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

data "aws_iam_policy_document" "jumphost_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "jumphost_role" {
  name               = "${var.name}-jumphost-role"
  assume_role_policy = data.aws_iam_policy_document.jumphost_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "jumphost_eks_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.jumphost_role.name
}

resource "aws_iam_role_policy_attachment" "jumphost_eks_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.jumphost_role.name
}

resource "aws_iam_role_policy_attachment" "jumphost_eks_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.jumphost_role.name
}

resource "aws_key_pair" "default" {
  key_name   = var.name
  public_key = var.public_key
}

resource "aws_instance" "jumphost" {
  ami           = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type = "t4g.small"
  subnet_id     = aws_subnet.public["us-east-1a"].id
  vpc_security_group_ids = [
    aws_security_group.jumphost.id
  ]
  key_name             = aws_key_pair.default.key_name
  iam_instance_profile = aws_iam_instance_profile.jumphost_profile.name

  tags = {
    Name = "${var.name}-jumphost"
  }

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/arm64/kubectl"
    chmod +x ./kubectl
    mv ./kubectl /usr/local/bin/kubectl
    aws eks update-kubeconfig --name ${aws_eks_cluster.default.name} --region us-east-1
  EOF
}

resource "aws_iam_instance_profile" "jumphost_profile" {
  name = "${var.name}-jumphost-profile"
  role = aws_iam_role.jumphost_role.name
}

resource "aws_security_group" "jumphost" {
  vpc_id = aws_vpc.default.id
  name   = "${var.name}-jumphost"
}

resource "aws_security_group_rule" "jumphost_egress_all" {
  security_group_id = aws_security_group.jumphost.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "jumphost_ingress_ssh" {
  security_group_id = aws_security_group.jumphost.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = [var.admin_cidr]
}

output "jumphost" {
  value = aws_instance.jumphost.public_ip
}
