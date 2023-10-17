

# Create an SNS topic
resource "aws_sns_topic" "SNSTopic" {
  name = "messageTopic"
}

# Subscribe an email address to the SNS topic
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.SNSTopic.arn
  protocol  = "email"
  endpoint  = "dainius.stepulevicius@t4connex.com,benjamin.wai@t4connex.com"
}

# Store the SNS topic ARN in SSM Parameter Store
resource "aws_ssm_parameter" "sns_topic_arn" {
  name  = "/config/message_develop/contactustopic-arn"
  type  = "String"
  value = aws_sns_topic.SNSTopic.arn
}

output "sns_topic_arn" {
  value = aws_sns_topic.SNSTopic.arn
}
