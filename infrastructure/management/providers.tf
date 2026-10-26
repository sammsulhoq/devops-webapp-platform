provider "aws" {
  region = "ap-south-1"

  default_tags {
    tags = {
      Project     = "devops-webapp-platform"
      Environment = "management"
      ManagedBy   = "terraform"
      Owner       = "sammsulhoq"
    }
  }
}
