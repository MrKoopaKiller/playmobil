terraform {
  backend "s3" {
    bucket  = "<BUCKET_NAME>"
    encrypt = "true"
    key     = "vpc/vpc.tfstate"
    region  = "us-east-2"
  }
}
