output "alb" {
  value = "http://${aws_alb.messageapp.dns_name}"
}