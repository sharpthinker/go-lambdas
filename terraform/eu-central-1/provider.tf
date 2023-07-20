provider "aws" {
  region = "eu-central-1"
}

terraform {
	required_providers {
		aws = {
	    version = "~> 5.8.0"
		}
  }
}
