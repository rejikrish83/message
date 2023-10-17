resource "aws_ecs_cluster" "messageapp" {
  name = "messageapp-cluster"
  
   setting {
    name  = "containerInsights"
    value = "enabled"
  }
}