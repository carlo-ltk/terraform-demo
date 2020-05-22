provider "aws" {
  version = "~> 2.62"
  profile = "default"
  region  = "us-east-1"
}

# Existing Resource ID: ydr-sample-web-app
resource "aws_s3_bucket" "web_app" {
    bucket = lookup(local.web_app_bucket, terraform.workspace)
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
                    "Resource": lookup(local.web_app_bucket_resource, terraform.workspace)
                }
            ]
        }
    )
}

locals {
    web_app_bucket = {
        staging = "ydr-stg-sample-web-app"
        default = "ydr-sample-web-app"
    }
    web_app_s3_origin_id =  {
        staging = "S3-ydr-stg-sample-web-app"
        default = "S3-ydr-sample-web-app"
    }
    web_app_bucket_resource = {
        staging = "arn:aws:s3:::ydr-stg-sample-web-app/*"
        default = "arn:aws:s3:::ydr-sample-web-app/*"
    }

}

# Existing Resource id: E3187LMRS3KU82
resource "aws_cloudfront_distribution" "cf" {
    enabled = true
    is_ipv6_enabled = true
    origin {
        domain_name = aws_s3_bucket.web_app.bucket_regional_domain_name
        origin_id = lookup(local.web_app_s3_origin_id, terraform.workspace)
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
        target_origin_id            = lookup(local.web_app_s3_origin_id, terraform.workspace)
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


