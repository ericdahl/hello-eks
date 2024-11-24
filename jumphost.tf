data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
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
  key_name = aws_key_pair.default.key_name

  tags = {
    Name = "${var.name}-jumphost"
  }
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
