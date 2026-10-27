terraform {
  backend "s3" {
    bucket       = "hv-capstone-tfstate-483510445289-ap-south-1"
    key          = "platform/dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
