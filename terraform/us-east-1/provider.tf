provider "aws" {
  region = "us-east-1"
}

terraform {
	required_providers {
		aws = {
	    version = "~> 5.8.0"
		}
  }
}
