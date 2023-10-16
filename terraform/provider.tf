provider "aws" {
  region = "eu-north-1"
}
terraform {
  # Terraform back-end configuration
  	backend "s3" {
  	bucket         = "messageappbucket"
    encrypt        = true
    key            = "messageappbucket/terraform.tfstate"
    region         = "eu-north-1	"
    dynamodb_table = "messagingApp"
  }
}