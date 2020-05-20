provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# Existing Resource ID: ydr-sample-web-app
resource "aws_s3_bucket" "web_app" {
    bucket = "ydr-sample-web-app"
    acl = "private"
}

resource "aws_s3_bucket_policy" "web_app" {
    bucket  = aws_s3_bucket.web_app.id
    policy = jsonencode (
        {
            "Version": "2012-10-17",
            "Id": "Policy1589994285263",
            "Statement": [
                {
                    "Sid": "Stmt1589994284139",
                    "Effect": "Allow",
                    "Principal": "*",
                    "Action": "s3:GetObject",
                    "Resource": "arn:aws:s3:::ydr-sample-web-app/*"
                }
            ]
        }
    )
}

locals {
  web_app_s3_origin_id = "S3-ydr-sample-web-app"
}

# Existing Resource id: E3187LMRS3KU82
resource "aws_cloudfront_distribution" "cf" {
    enabled = true
    is_ipv6_enabled = true
    origin {
        domain_name = aws_s3_bucket.web_app.bucket_regional_domain_name
        origin_id = local.web_app_s3_origin_id
    }
    restrictions {
        geo_restriction {
        restriction_type = "none"
        }
    }
    viewer_certificate {
        cloudfront_default_certificate = true
    }
    default_cache_behavior {
        allowed_methods             = ["GET", "HEAD"]
        cached_methods              = ["GET", "HEAD"]
        target_origin_id            = local.web_app_s3_origin_id
        default_ttl                 = 86400
        max_ttl                     = 31536000
        viewer_protocol_policy      = "redirect-to-https"
        forwarded_values {
            query_string = false

            cookies {
                forward = "none"
            }
        }
    }
}


