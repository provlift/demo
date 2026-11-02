provider "aws" {
  region = "us-east-1"
}

provider "cloudflare" {}

resource "random_pet" "bucket" {}

resource "aws_s3_bucket" "assets" {
  bucket = "provlift-demo-${random_pet.bucket.id}"
}
