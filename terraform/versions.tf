terraform {
  required_version = "~> 1.2.8"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #  Lock version to prevent unexpected problems
      version = "~> 4.16"
    }

  }
}