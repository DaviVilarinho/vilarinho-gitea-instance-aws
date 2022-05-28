resource "aws_security_group" "gitea" {
  name = "gitea-security-group"
  description = "Allowing http traffic and ssh"

  ingress {
    description = "SSH to host"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }

  ingress {
    description = "SSH to gitea repos"
    from_port = 2222
    to_port = 2222
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

data "aws_iam_policy_document" "gitea_role_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "gitea_s3" {
  statement {
    sid = "S3ACCESSBUCKETS"
    effect = "Allow"
    actions = [ "s3:*", "s3api:*" ]
    resources = [ 
      data.aws_s3_bucket.backup_and_data.arn, aws_s3_bucket.gitea.arn,
      "${data.aws_s3_bucket.backup_and_data.arn}/*", "${aws_s3_bucket.gitea.arn}/*"
    ]
  } 
  statement {
    sid = "S3LIST"
    effect = "Allow"
    actions = [ 
      "s3:ListAllMyBuckets", 
      "s3:GetBucketLocation"  
    ]
    resources = [ "arn:aws:s3:::*" ]
  } 
}

resource "aws_iam_role" "gitea" {
  name_prefix = "gitea-instance-role" 
  path = "/automation/gitea/"
  assume_role_policy = data.aws_iam_policy_document.gitea_role_assume_role.json
  inline_policy {
    name = "GITEA_S3_ACCESS"
    policy = data.aws_iam_policy_document.gitea_s3.json 
  }
}

resource "aws_iam_instance_profile" "gitea_instance" {
  name = "gitea-instance-instance-profile"
  role = aws_iam_role.gitea.id
}