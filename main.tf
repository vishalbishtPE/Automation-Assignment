provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::488599217855:role/qtrainee-sso-pe-role"
  }  
  region = "us-east"
}
