#############################
# Web App Bucket
#############################

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

#############################
# Tropical Vault Bucket
#############################

resource "aws_s3_bucket" "tropical_vault_bucket" {
  bucket = "tropical-vault-bucket-${replace(lower(var.iam_role_name), "studentrole-", "")}"
}

resource "aws_s3_bucket_policy" "tropical_vault_bucket_policy" {
  bucket = aws_s3_bucket.tropical_vault_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "AllowLambdaReadAccess",
      Effect    = "Allow",
      Principal = {
        AWS = data.aws_iam_role.web_lambda_exec_role.arn
      },
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.tropical_vault_bucket.arn}/*"
    }]
  })
}

resource "aws_s3_object" "tropical_image" {
  bucket = aws_s3_bucket.tropical_vault_bucket.id
  key    = "public/tropical.png"
  source = "image/tropical.png"
}

resource "aws_s3_object" "secret_image" {
  bucket = aws_s3_bucket.tropical_vault_bucket.id
  key    = "critical/financials.png"
  source = "image/financials.png"
}
