locals {
    main_domain = "maxranderson.com"
    www_domain = "www.${local.main_domain}"
}

resource "aws_acm_certificate" "main_domain_certificate" {
  domain_name       = local.main_domain
  validation_method = "DNS"
  key_algorithm = "RSA_2048"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_zone" "main_domain" {
  name = local.main_domain
  
}

resource "aws_route53_record" "main_domain_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main_domain_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main_domain.zone_id
}

resource "aws_acm_certificate_validation" "main_domain_validation" {
  certificate_arn         = aws_acm_certificate.main_domain_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.main_domain_validation : record.fqdn]
}