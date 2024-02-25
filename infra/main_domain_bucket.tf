resource "aws_s3_bucket" "main_domain" {
  bucket = local.main_domain

  tags = {
    Description        = "Bucket for my main domain artifacts"
  }
}

resource "aws_s3_bucket_public_access_block" "main_domain" {
  bucket = aws_s3_bucket.main_domain.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "main_domain" {
  bucket = aws_s3_bucket.main_domain.id
  policy = data.aws_iam_policy_document.main_domain.json
}

data "aws_iam_policy_document" "main_domain" {
  statement {

    sid = "AllowAccessToWebsiteFiles"

    principals {
      type = "Service"
      identifiers = [ "cloudfront.amazonaws.com" ]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "${aws_s3_bucket.main_domain.arn}/*",
      aws_s3_bucket.main_domain.arn,
    ]

    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [ aws_cloudfront_distribution.domain.arn  ]
    }
  }
}

