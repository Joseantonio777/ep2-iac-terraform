# ---------------------------------------------------------
# CDN: Amazon S3 (Privado) + CloudFront (OAC)
# Controlado por var.habilitar_cdn
# ---------------------------------------------------------

resource "random_id" "bucket_suffix" {
  count       = var.habilitar_cdn ? 1 : 0
  byte_length = 4
}

resource "aws_s3_bucket" "cdn" {
  count         = var.habilitar_cdn ? 1 : 0
  bucket        = "${local.nombre_base}-cdn-${random_id.bucket_suffix[0].hex}"
  force_destroy = true

  tags = merge(local.tags_comunes, {
    Name = "${local.nombre_base}-cdn-bucket"
  })
}

resource "aws_s3_bucket_versioning" "cdn" {
  count  = var.habilitar_cdn ? 1 : 0
  bucket = aws_s3_bucket.cdn[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "cdn" {
  count  = var.habilitar_cdn ? 1 : 0
  bucket = aws_s3_bucket.cdn[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "cdn" {
  count                             = var.habilitar_cdn ? 1 : 0
  name                              = "${local.nombre_base}-oac"
  description                       = "OAC para bucket S3 privado del proyecto ${var.proyecto}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn" {
  count               = var.habilitar_cdn ? 1 : 0
  enabled             = true
  comment             = "Distribucion CloudFront para assets estaticos (${var.environment})"
  default_root_object = "prueba-cdn.png"

  origin {
    domain_name              = aws_s3_bucket.cdn[0].bucket_regional_domain_name
    origin_id                = "s3-${aws_s3_bucket.cdn[0].id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.cdn[0].id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-${aws_s3_bucket.cdn[0].id}"

    # Politica administrada AWS: Managed-CachingOptimized
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(local.tags_comunes, {
    Name = "${local.nombre_base}-cloudfront"
  })
}

data "aws_iam_policy_document" "cdn_s3_policy" {
  count = var.habilitar_cdn ? 1 : 0

  statement {
    sid       = "AllowCloudFrontServicePrincipalReadOnly"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.cdn[0].arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cdn[0].arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cdn" {
  count  = var.habilitar_cdn ? 1 : 0
  bucket = aws_s3_bucket.cdn[0].id
  policy = data.aws_iam_policy_document.cdn_s3_policy[0].json

  depends_on = [aws_s3_bucket_public_access_block.cdn]
}

resource "aws_s3_object" "prueba" {
  count        = var.habilitar_cdn ? 1 : 0
  bucket       = aws_s3_bucket.cdn[0].id
  key          = "prueba-cdn.png"
  source       = "${path.module}/assets/prueba-cdn.png"
  etag         = filemd5("${path.module}/assets/prueba-cdn.png")
  content_type = "image/png"

  depends_on = [aws_s3_bucket.cdn]
}
