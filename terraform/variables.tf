
variable "region" {
  type    = string
  default = "eu-north-1"
}

variable "sns_topic_name" {
  type    = string
  default = "Message_Contactus_SNS"
}

# Define a list of email addresses
variable "email_addresses" {
  type    = list(string)
  default = ["dainius.stepulevicius@t4connex.com","benjamin.wai@t4connex.com"]
}