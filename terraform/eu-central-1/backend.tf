terraform {
  backend "s3" {
    bucket = "terraform-backend-test-jetbrains-eu-central-1"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}
