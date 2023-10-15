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
  default = "us-west-2"
}

variable "sns_topic_name" {
  type    = string
  default = "CCP_Oneclick_SNS"
}