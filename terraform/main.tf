provider "aws" {
  region = "us-east-1"  # Change to your desired AWS region
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "example" {
  count             = 2
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.1.${count.index * 2}.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_security_group" "example" {
  name_prefix = "example-"
  description = "Allow incoming traffic"
  vpc_id      = aws_vpc.example.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "example" {
  name = "example-cluster"
}

resource "aws_ecs_task_definition" "example" {
  family                   = "example-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.example.arn

  cpu = "256"    # Adjust based on your application's requirements
  memory = "512" # Adjust based on your application's requirements

  container_definitions = <<DEFINITION
  [
    {
      "name": "example-container",
      "image": "your-ecr-repository-url/your-spring-boot-app:latest",
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

resource "aws_iam_role" "example" {
  name = "example-task-execution-role"
}

resource "aws_iam_policy" "example" {
  name = "example-task-policy"

  description = "Example Task Policy"

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

resource "aws_iam_role_policy_attachment" "example" {
  policy_arn = aws_iam_policy.example.arn
  role       = aws_iam_role.example.name
}

resource "aws_iam_instance_profile" "example" {
  name = "example-instance-profile"

  role = aws_iam_role.example.name
}

resource "aws_ecs_service" "example" {
  name            = "example-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn
  launch_type     = "FARGATE"
  network_configuration {
    subnets = aws_subnet.example[*].id
    security_groups = [aws_security_group.example.id]
  }
  depends_on      = [aws_ecs_task_definition.example]
}

resource "aws_ecs_capacity_provider" "example" {
  name              = "example-capacity-provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.example.arn
    managed_termination_protection = "DISABLED"
  }
  enable_ecs_managed_tags = true
  tags = {
    Name = "example-capacity-provider"
  }
}
