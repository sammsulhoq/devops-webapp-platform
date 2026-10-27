provider "aws" {
  region = "ap-south-1"

  default_tags {
    tags = {
      Project     = "devops-webapp-platform"
      Environment = "dev"
      ManagedBy   = "terraform"
      Owner       = "sammsulhoq"
    }
  }
}
