variable "region" {
  default = "eu-central-1"
}

variable "iam_role_name" {
  description = "A unique name for the student, passed in from the workflow."
  type        = string
}