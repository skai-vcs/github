terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "6.4.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "5.80.0"
    }
  }
}

provider "github" {
  owner = var.org_name
  token = var.github_token
}

provider "aws" {
  region  = var.region
  default_tags {
    tags = {
      Code    = "COMMON/github/repositories"
      Managed = "terraform"
    }
  }
}