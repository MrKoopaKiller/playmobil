terraform {
  backend "s3" {
    bucket = "<BUCKET_NAME>"
    encrypt = "true"
    key    = "app/app.tfstate"
    region = "us-east-2"
  }
}
