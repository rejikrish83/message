
resource "aws_vpc" "messageapp" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "messageapp" {

  
  count                   = 2
  vpc_id                  = aws_vpc.messageapp.id
  cidr_block              = element(["10.1.1.0/24", "10.1.2.0/24"], count.index)
  availability_zone       = element(["eu-north-1a", "eu-north-1b"], count.index)
  map_public_ip_on_launch = true
}


resource "aws_security_group" "messageapp" {
  name_prefix = "messageapp-"
  description = "Allow incoming traffic"
  vpc_id      = aws_vpc.messageapp.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "messageapp" {
  type        = "ingress"
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.messageapp.id
}

resource "aws_ecs_cluster" "messageapp" {
  name = "messageapp-cluster"
}

resource "aws_ecs_task_definition" "messageapp" {
  family                   = "messageapp-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.messageapp.arn
  task_role_arn            = aws_iam_role.task_role.arn

  cpu = "256"    # Adjust based on your application's requirements
  memory = "512" # Adjust based on your application's requirements

  container_definitions = <<DEFINITION
  [
    {
      "name": "messageapp-container",
      "image": "470502905291.dkr.ecr.eu-north-1.amazonaws.com/message-app:latest",
      "memory": 512,
      "cpu": 256,
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
resource "aws_iam_role" "task_role" {
  name = "ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}
resource "aws_iam_role" "messageapp" {
  name = "messageapp-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "messageapp" {
  name = "messageapp-task-policy"

  description = "messageapp Task Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetAuthorizationToken",
        "ecr:GetRegistryCatalogData",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:GetDownloadUrlForLayer"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_ecs_service" "messageapp" {
  name            = "messageapp-service"
  cluster         = aws_ecs_cluster.messageapp.id
  task_definition = aws_ecs_task_definition.messageapp.arn
  launch_type     = "FARGATE"
  network_configuration {
    subnets = aws_subnet.messageapp[*].id
    security_groups = [aws_security_group.messageapp.id]
  }
  depends_on      = [aws_ecs_task_definition.messageapp]
}



resource "aws_lb_listener" "messageapp" {
  load_balancer_arn = aws_lb.messageapp.arn
  port             = 80
  protocol         = "HTTP"

  default_action {
    type             = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "OK"
    }
  }
}

resource "aws_lb_target_group" "messageapp" {
  name     = "my-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.messageapp.id
}

resource "aws_lb_listener_rule" "messageapp" {
  listener_arn = aws_lb_listener.messageapp.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.messageapp.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

output "load_balancer_dns_name" {
  value = aws_lb.messageapp.dns_name
}


resource "aws_lb" "messageapp" {
  name               = "messageapp"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.messageapp[*].id
}

