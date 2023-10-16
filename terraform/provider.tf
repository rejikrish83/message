provider "aws" {
  region = "eu-north-1"
}
terraform {
  # Terraform back-end configuration
  backend "s3" {
    encrypt        = true
    key            = "message-contactus/terraform.tfstate"
    region         = "eu-north-1	"
    dynamodb_table = "messagingApp"
  }
}