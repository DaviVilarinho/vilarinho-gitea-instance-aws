resource "aws_s3_object" "docker_compose" {
  bucket = aws_s3_bucket.gitea.id
  key = "configs/docker-compose.yml" 
  source = local.compose_path
  etag = filemd5(local.compose_path)
}

resource "aws_s3_object" "app_ini" {
  bucket = aws_s3_bucket.gitea.id
  key = "configs/gitea/gitea/conf/app.ini" 
  source = local.app_ini_path
  etag = filemd5(local.app_ini_path)
}
