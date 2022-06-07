
resource "aws_s3_bucket" "bum" {
  bucket = "my34bucket.nameonmetyry"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}



resource "aws_s3_object" "object" {
  for_each = fileset("/home/paragon/Documents/LAMP/php-mysql-crud/", "**/*") 
  bucket = "my34bucket.nameonmetyry"
  key    = each.value
  source = "/home/paragon/Documents/LAMP/php-mysql-crud/${each.value}"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = 
  etag = filemd5("/home/paragon/Documents/LAMP/php-mysql-crud/${each.value}")
  depends_on = [aws_s3_bucket.bum]
}


