data "aws_route53_zone" "website" {
  name         = "${local.website}."
}

resource "aws_route53_record" "gitea" {
  zone_id = data.aws_route53_zone.website.zone_id
  name    = "git.${data.aws_route53_zone.website.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.gitea.public_ip]
}

resource "aws_security_group" "gitea" {
  name = "gitea-security-group"
  description = "Allowing http traffic and ssh"

  ingress {
    description = "SSH to gitea repos"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }

  ingress {
    description = "HTTP"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "gitea" {
  ami = "ami-0022f774911c1d690"   
  instance_type = "t3.nano"
  associate_public_ip_address = true
  security_groups = [ aws_security_group.gitea.name ]
}
