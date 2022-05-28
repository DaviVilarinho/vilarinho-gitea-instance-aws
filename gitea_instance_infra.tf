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

resource "aws_instance" "gitea" {
  ami = "ami-0022f774911c1d690"   
  key_name = aws_key_pair.gitea.key_name
  instance_type = "t3.nano"
  associate_public_ip_address = true
  security_groups = [ aws_security_group.gitea.name ]
  user_data = templatefile("assets/gitea.tpl", {
    AWS_BUCKET = aws_s3_bucket.gitea.id 
    AWS_BACKUP_BUCKET = data.aws_s3_bucket.backup_and_data.id
  })
  user_data_replace_on_change = true 
  iam_instance_profile = aws_iam_instance_profile.gitea_instance.id
  depends_on = [
    aws_s3_object.docker_compose,
    aws_s3_object.app_ini
  ]
}
