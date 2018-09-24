
data "aws_ami" "freebsd_11" {
  most_recent = true

  filter {
    name = "owner-id"

    values = [
      "118940168514",
    ]
  }

  filter {
    name = "name"

    values = [
      "FreeBSD 11.1-STABLE-amd64*",
    ]
  }
}

resource "aws_instance" "jumphost" {
  ami                    = "${data.aws_ami.freebsd_11.image_id}"
  instance_type          = "t2.small"
  subnet_id              = "${module.vpc.subnet_public1}"
  vpc_security_group_ids = ["${module.vpc.sg_allow_22}", "${module.vpc.sg_allow_egress}"]
  key_name               = "${var.key_name}"

  user_data = <<EOF
#!/usr/bin/env sh

export ASSUME_ALWAYS_YES=YES

pkg update -y
pkg install -y bash
chsh -s /usr/local/bin/bash ec2-user
EOF

  tags {
    Name = "jumphost"
  }
}
