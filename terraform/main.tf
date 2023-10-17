
resource "aws_security_group" "messageapp" {
  name_prefix = "messageapp-"
  description = "Allow incoming traffic"
  vpc_id      = aws_vpc.messageapp.id
}

resource "aws_security_group_rule" "messageapp_ingress_alb" {
  type        = "ingress"
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.messageapp.id
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/messageapp/app"
  retention_in_days = 3
}

resource "aws_ecs_task_definition" "messageapp" {
  family                   = "messageapp-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.messageapp.arn
  

  cpu = "1024"    # Adjust based on your application's requirements
  memory = "2048" # Adjust based on your application's requirements

  container_definitions = <<DEFINITION
  [
    {
      "name": "messageapp-container",
      "image": "470502905291.dkr.ecr.eu-north-1.amazonaws.com/message-app-repo",
      "memory": 1024,
      "cpu": 512,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        }
      ]
    }
  ]
  DEFINITION
}


resource "aws_ecs_service" "messageapp" {
  name            = "messageapp-service"
  cluster         = aws_ecs_cluster.messageapp.id
  task_definition = aws_ecs_task_definition.messageapp.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  network_configuration {
    subnets = aws_subnet.messageapp[*].id
    security_groups = [aws_security_group.messageapp.id]
  }
  depends_on      = [aws_alb.messageapp]
  health_check_grace_period_seconds = 300
  load_balancer {
    target_group_arn = aws_alb_target_group.messageapp.arn
    container_name   = "messageapp-container"
    container_port   = 8080
  }
}

resource "aws_appautoscaling_target" "messageapp" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.messageapp.name}/${aws_ecs_service.messageapp.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "messageapp" {
  name               = "app"
  resource_id        = aws_appautoscaling_target.messageapp.resource_id
  scalable_dimension = aws_appautoscaling_target.messageapp.scalable_dimension
  service_namespace  = aws_appautoscaling_target.messageapp.service_namespace

  policy_type = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    target_value = 25

    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label = "${aws_alb.messageapp.arn_suffix}/${aws_alb_target_group.messageapp.arn_suffix}"
    }
  }
}
