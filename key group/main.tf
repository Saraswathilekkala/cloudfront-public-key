resource "aws_cloudfront_public_key" "example" {
  comment     = "public key"
  encoded_key = "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6rL7tHJ9rd3F743CpW3R3vd5hxVJEiik6LEJByAnp7I872NmoGRCTGMomVGx0NMTl7oVn8vU2UAhkuYQnOty4Pvs2JWzkMY5cClhsmJfK+nuZpdfcpzbx3bCh7vhxDFJTpZFK7qF036C2DNP3lfLAwRuI9QXpOF0PJHgyyPzabXcz1OYvXgOxKdQw0UVlXCEpXLEGyeF3xf5ml/Crdo/RsxnXR9ktaOnHzp6QcfLWlSojyifxSZdvmXQa+kS1fB2igTaGuvKZClpKbB1akZwQ421KA1LqKiQer3NFW66GZNdtG0SPO8UOvh3MPkZLSIbePFvGQFLjxU626yzaMsbqwIDAQAB\n-----END PUBLIC KEY-----\n"
  name        = "ifp_${var.env}_pub_key"
}

resource "aws_cloudfront_key_group" "example" {
  comment = "example key group"
  items   = [aws_cloudfront_public_key.example.id]
  name    = "ifp_cf_${var.env}_key_gp"
}

