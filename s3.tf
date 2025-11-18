resource "aws_s3_bucket" "web_bucket" {
  bucket = "webapp-bucket-${replace(lower(var.iam_role_name), "studentrole-", "")}"
}

resource "aws_s3_bucket_policy" "web_bucket_policy" {
  bucket = aws_s3_bucket.web_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "AllowLambdaReadAccess",
      Effect    = "Allow",
      Principal = {
        AWS = data.aws_iam_role.web_lambda_exec_role.arn
      },
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.web_bucket.arn}/*"
    }]
  })
}

resource "aws_s3_object" "fruit_salad_image" {
  bucket = aws_s3_bucket.web_bucket.id
  key    = "fruitsalad.png"
  source = "image/fruitsalad.png"
}
resource "aws_s3_object" "Penguin_image" {
  bucket = aws_s3_bucket.web_bucket.id
  key    = "Penguin.png"
  source = "image/Penguin.png"
}
