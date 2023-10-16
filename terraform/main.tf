
resource "aws_vpc" "messageapp" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "messageapp" {
  count             = 2
  vpc_id            = aws_vpc.messageapp.id
  cidr_block        = "10.0.1.${count.index * 2}.0/24"
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
  name              = "messageapp-capacity-provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.messageapp.arn
    managed_termination_protection = "DISABLED"
  }
  enable_ecs_managed_tags = true
  tags = {
    Name = "messageapp-capacity-provider"
  }
}
