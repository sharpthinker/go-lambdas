terraform {
  backend "s3" {
    bucket = "terraform-backend-test-jetbrains-us-east-1"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
