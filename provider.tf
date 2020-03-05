terraform {
  required_version = ">= 0.12.9"
}

provider "google" {
   credentials = file(var.gcp_cred_file_path)
   project = var.gcp_project
   region  = var.gcp_region
   zone    = var.gcp_zone
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
