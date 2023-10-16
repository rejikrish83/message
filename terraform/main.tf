
resource "aws_vpc" "messageapp" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "messageapp" {
  count             = 2
  vpc_id            = aws_vpc.messageapp.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-north-1"
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

resource "aws_ecs_cluster" "messageapp" {
  name = "messageapp-cluster"
}

resource "aws_ecs_task_definition" "messageapp" {
  family                   = "messageapp-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.messageapp.arn

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

resource "aws_iam_role_policy_attachment" "messageapp" {
  policy_arn = aws_iam_policy.messageapp.arn
  role       = aws_iam_role.messageapp.name
}

resource "aws_iam_instance_profile" "messageapp" {
  name = "messageapp-instance-profile"

  role = aws_iam_role.messageapp.name
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


resource "aws_ecs_capacity_provider" "messageapp" {
  name = "messageapp-capacity-provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.messageapp.arn
    managed_scaling {
      target_capacity = 70
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 10
      instance_warmup_period = 60
    }
  }
  tags = {
    Environment = "Production"
  }
}

resource "aws_autoscaling_group" "messageapp" {
  name = "messageapp-autoscaling-group"
  launch_template {
    id = aws_launch_template.messageapp.id
    version = "$Latest"
  }
  min_size = 2
  max_size = 10
  desired_capacity = 4
  target_group_arns = [aws_lb_target_group.messageapp.arn]
  availability_zones = ["eu-north-1a", "eu-north-1b"]
}

resource "aws_launch_template" "messageapp" {
  name_prefix = "messageapp-launch-template"
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp2"
    }
  }
  iam_instance_profile {
    name = "messageapp-iam-instance-profile"
  }
  network_interfaces {
    associate_public_ip_address = true
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "messageapp-instance"
    }
  }
}

resource "aws_lb_target_group" "messageapp" {
  name     = "messageapp-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.messageapp.id
}

