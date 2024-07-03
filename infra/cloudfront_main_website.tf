resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "domain-cloudfront-logs"

  tags = {
    Description        = "Bucket for my website artifacts"
  }
}

resource "aws_s3_bucket_policy" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  policy = data.aws_iam_policy_document.cloudfront_logs.json
}

data "aws_iam_policy_document" "cloudfront_logs" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.cloudfront_logs.arn,
      "${aws_s3_bucket.cloudfront_logs.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_ownership_controls" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

data "aws_canonical_user_id" "current" {}

resource "aws_s3_bucket_acl" "cloudfront_logs" {
  depends_on = [ aws_s3_bucket_ownership_controls.cloudfront_logs ]
  bucket = aws_s3_bucket.cloudfront_logs.id
  access_control_policy {
    grant {
      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }

    grant {
      grantee {
        type = "Group"
        uri  = "http://acs.amazonaws.com/groups/s3/LogDelivery"
      }
      permission = "FULL_CONTROL"
    }

    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
}

resource "aws_cloudfront_origin_access_control" "domain" {
  name                              = "domainOrigin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

locals {
  cloudfront_origin = "mainWebsite"
  main_page = "index.html"
}

resource "aws_cloudfront_distribution" "domain" {
  origin {
    domain_name              = aws_s3_bucket.main_domain.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.domain.id
    origin_id                = local.cloudfront_origin
  }

  aliases = [ local.main_domain ]

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = local.main_page

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_logs.bucket_domain_name
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.cloudfront_origin

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 1800
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations = []
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.main_domain_certificate.id
    ssl_support_method = "sni-only"
  }

  wait_for_deployment = false
}

resource "aws_route53_record" "main_domain" {
  zone_id = aws_route53_zone.main_domain.zone_id
  name    = ""
  type    = "A"
  alias {
    name = aws_cloudfront_distribution.domain.domain_name
    zone_id = aws_cloudfront_distribution.domain.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ipv6_main_domain" {
  zone_id = aws_route53_zone.main_domain.zone_id
  name    = ""
  type    = "AAAA"
  alias {
    name = aws_cloudfront_distribution.domain.domain_name
    zone_id = aws_cloudfront_distribution.domain.hosted_zone_id
    evaluate_target_health = false
  }
}