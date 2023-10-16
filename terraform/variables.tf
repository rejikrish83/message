variable "account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "cross_account_accountid" {
  type        = string
  description = "AWS Account ID"
}

variable "region" {
  type    = string
  default = "eu-north-1"
}

variable "sns_topic_name" {
  type    = string
  default = "Message_Contactus_SNS"
}