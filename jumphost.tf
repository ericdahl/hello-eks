data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "jumphost" {
  ami                    = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type          = "t2.small"
  subnet_id              = module.vpc.subnet_public1
  vpc_security_group_ids = [module.vpc.sg_allow_22, module.vpc.sg_allow_egress]
  key_name               = var.key_name

  tags = {
    Name = "jumphost"
  }
}

