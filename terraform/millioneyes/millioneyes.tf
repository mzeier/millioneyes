resource "aws_vpc" "vpc" {
  cidr_block = "10.100.0.0/24"

  instance_tenancy   = "default"
  enable_classiclink = false

  tags = {
    Name    = "millioneyes"
    cluster = "ops"
  }
}

resource "aws_internet_gateway" "vpc-inet" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_default_route_table" "default-routes" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc-inet.id
  }
}

resource "aws_subnet" "primary-subnet" {
  cidr_block                      = "10.100.0.0/24"
  vpc_id                          = aws_vpc.vpc.id
  assign_ipv6_address_on_creation = false
  tags = {
    Name = "millioneyes.default"
  }
}

resource "aws_security_group" "ingress-wavefront" {
  name        = "millioneyes.ingress-admin"
  description = "enables ingress from our management vpc and corp"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    role    = "millioneyes"
    cluster = "ops"
  }
}

resource "aws_security_group_rule" "admin" {
  security_group_id = aws_security_group.ingress-wavefront.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  type              = "ingress"
  cidr_blocks = [
    "73.202.145.79/32",
  ]
}

resource "aws_security_group_rule" "egress-all" {
  security_group_id = aws_security_group.ingress-wavefront.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_eip" "million-eyes-eip" {
  vpc = true
}

resource "aws_eip_association" "million-eyes-eip-assoc" {
  allow_reassociation = true
  instance_id         = aws_instance.monitor.id
  allocation_id       = aws_eip.million-eyes-eip.id
}

resource "aws_instance" "monitor" {
  key_name = aws_key_pair.millioneyes.key_name
  lifecycle {
    ignore_changes = [ami]
  }
  instance_type               = "t3.small"
  associate_public_ip_address = true
  private_ip                  = "10.100.0.15"
  vpc_security_group_ids = [
    aws_security_group.ingress-wavefront.id,
  ]
  subnet_id = aws_subnet.primary-subnet.id
  ami       = data.aws_ami.ubuntu-store.id

  tags = {
    Name    = "[millioneyes-${var.region}]"
    cluster = "ops"
    role    = "millioneyes"
    region  = var.region
  }

  depends_on = [aws_internet_gateway.vpc-inet]
}

resource "aws_key_pair" "millioneyes" {
  key_name   = "mrz-ssh"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCsZYkb6DPO1OTIaT1jCG8sbCsoR9KHd3EDjGnuGXoA68W5AcEy30CAy1Rzs5QCvpMhIhT5WLUaHOCMoIl3OY8kZAf92y+69+i4jrQwijw/XRb+WKRw2Zxh572D9dW0UBdrWVeu/qMAZspUYJ08ZEFPFnYpwFAFa2F8OqtvahtJHJQg3RA8x8C65RpPmlE/+agwemfr++DQSg2g8JENm5+LwUB00+IWzcrrTp1ihmXv5rGoPuy8MYYPjqz/0QmVwHAUKQBitjKzLv7DMOCr3CkMgnXq113mVhwiwp6uDGrTwSOb+J4YpdLrcLpuGAOWpxOq5g2DGwJcmGw2DRVuDPnrHe4qs6EyRBSVe4ExJ629GDxVEhl5/YgdWauFlk0HCJ8J2dgGDuEDhOkhzrxH4fMJwlaEzG1nYcCViMsNpXMOHgBxWjDzQINX2d7jY725dKnPFQZRas7KEE2vfOTL1hfnrsoVCeTXgUrdy5TSnZvCXUtnC3sIcdcHV/hSwMRcsrM6J4Ym8T2HuCVe6QN0UO/HPkQ9xbI3Jry51G7F/BdfT06F8sOGOQ3frVRZ3Q/tawGlN4e+uPIr5LQpRK/JcUVJp0dv/O2Or8AVuj+ATtwBnRnNCFNXB0KEMacUShup+6LItnhZtpKVn7CUFuauwcEkOupj89tEFNAE/RwJKd9DPQ== mrz@lacework_rsa"
}

data "aws_ami" "ubuntu-store" {
  filter {
    name = "architecture"
    values = [
      "x86_64",
    ]
  }
  filter {
    name = "name"
    values = [
      "*ubuntu-focal-20.04-amd64-server-*",
    ]
  }

  filter {
    name = "virtualization-type"
    values = [
      "hvm",
    ]
  }

  filter {
    name = "root-device-type"
    values = [
      "ebs",
    ]
  }

  owners = [
    "099720109477",
  ]
  most_recent = true
}

output "public-ip" {
  value = aws_eip.million-eyes-eip.public_ip
}

