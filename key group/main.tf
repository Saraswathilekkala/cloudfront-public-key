resource "aws_cloudfront_public_key" "example" {
  comment     = "public key"
  encoded_key = "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6rL7tHJ9rd3F743CpW3R3vd5hxVJEiik6LEJByAnp7I872NmoGRCTGMomVGx0NMTl7oVn8vU2UAhkuYQnOty4Pvs2JWzkMY5cClhsmJfK+nuZpdfcpzbx3bCh7vhxDFJTpZFK7qF036C2DNP3lfLAwRuI9QXpOF0PJHgyyPzabXcz1OYvXgOxKdQw0UVlXCEpXLEGyeF3xf5ml/Crdo/RsxnXR9ktaOnHzp6QcfLWlSojyifxSZdvmXQa+kS1fB2igTaGuvKZClpKbB1akZwQ421KA1LqKiQer3NFW66GZNdtG0SPO8UOvh3MPkZLSIbePFvGQFLjxU626yzaMsbqwIDAQAB\n-----END PUBLIC KEY-----\n"
  name        = "${var.env}_pub_key"
}

resource "aws_cloudfront_key_group" "example" {
  comment = "example key group"
  items   = [aws_cloudfront_public_key.example.id]
  name    = "cf_${var.env}_key_gp"
}

##########################
resource "aws_cloudfront_response_headers_policy" "example" {
  name    = "cors-response"
  comment = "test comment"

  cors_config {
    access_control_allow_credentials = false

    access_control_allow_headers {
      items = ["*"]
    }

    access_control_allow_methods {
      items = ["ALL"]
    }

    access_control_allow_origins {
      items = ["*"]
    }
    
    access_control_max_age_sec = "600"

    origin_override = true
  }
}

resource "aws_cloudfront_origin_request_policy" "example" {
  name    = "example-policy"
  comment = "example comment"
  cookies_config {
    cookie_behavior = "whitelist"
    cookies {
      items = ["example"]
    }
  }
  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["example"]
    }
  }
  query_strings_config {
    query_string_behavior = "whitelist"
    query_strings {
      items = ["example"]
    }
  }
}

################# Distribution ####################

resource "aws_cloudfront_cache_policy" "cache_policy" {
  name        = "pgi-${var.env}cache-policy"
  comment     = "CAche policy for env"
  default_ttl = 600
  max_ttl     = 31536000
  min_ttl     = 1
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
      
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip = true
  }

}



###############################  creating clound front origin access control  ########################
resource "aws_cloudfront_origin_access_control" "cf_s3_portal_origin" {
 # depends_on = [aws_s3_bucket.pgi-portal-s3]
  name                              = "pgi-${var.env}-portal.s3-eu-west-1.amazonaws.com"
  description                       = "Origin access control policy for s3 portal"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
###############################  creating clound front distribution ########################
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = var.domain_name
    origin_id = var.origin_id
    origin_access_control_id   =  aws_cloudfront_origin_access_control.cf_s3_portal_origin.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = var.default_root_object

 # logging_config {
  #  include_cookies = false
   # bucket          = "pgi-dev-portal.pgi.pearsondev.tech"
    #prefix          = "myprefix"
  #}

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.target_origin_id
    cache_policy_id = aws_cloudfront_cache_policy.cache_policy.id
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    response_headers_policy_id = "${aws_cloudfront_response_headers_policy.example.id}"
    trusted_key_groups = ["${aws_cloudfront_key_group.example.id}"]
  }
  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = var.restriction_type
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = var.cloudfront_default_certificate
    ssl_support_method             = var.ssl_support_method
  }
}
