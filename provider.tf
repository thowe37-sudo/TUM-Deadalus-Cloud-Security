provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      TerraformManagedBy = var.iam_role_name
    }
  }
}
