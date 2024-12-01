#############################################
# Get current AWS account ID
data "aws_caller_identity" "current" {}
#############################################

# S3 Bucket

resource "aws_s3_bucket" "s3-image-bucket" {
  bucket = var.s3_name
  force_destroy = true

  tags = {
    Name = "${local.prefix}-rds-bucket"
  }

}

resource "aws_s3_bucket_policy" "s3_cf_bucket_policy" {
  bucket = aws_s3_bucket.s3-image-bucket.id
  policy = <<EOF
{
    "Version": "2008-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
        {
            "Sid": "AllowCloudFrontServicePrincipal",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.s3-image-bucket.arn}/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.cf_s3_distribution.id}"
                }
            }
        }
    ]
}
EOF
}



# Cloud Front & OAC

resource "aws_cloudfront_distribution" "cf_s3_distribution" {
    depends_on = [ aws_s3_bucket.s3-image-bucket ]
  origin {
    domain_name              = aws_s3_bucket.s3-image-bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac-rds-s3.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true


  

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id


    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    
    }
  }

  

  viewer_certificate {
  cloudfront_default_certificate = true
  }

    tags = {
    Name = "${local.prefix}-rds-cf"
  }

  

}

resource "aws_cloudfront_origin_access_control" "oac-rds-s3" {
  name                              = aws_s3_bucket.s3-image-bucket.id
  description                       = "OAC Prevent direct access to S3 Bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
