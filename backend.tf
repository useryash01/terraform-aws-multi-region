terraform {
  backend "s3" {
    bucket       = "yash-mayekar-tfstate-20260728"
    key          = "terraform-aws-multi-region/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}
