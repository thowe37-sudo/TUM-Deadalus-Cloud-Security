terraform {
  backend "s3" {
    bucket         = "tum-workshop-tfstate" 
    region         = "eu-central-1"
    encrypt        = true
  }
}
