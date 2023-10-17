resource "aws_alb_target_group" "messageapp" {
  name        = "messageappawsalbtargetgroup"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.messageapp.id
  target_type = "ip"

  deregistration_delay = 0
}

resource "aws_alb" "messageapp" {
  name            = "messageappawsalb"
  subnets         = aws_subnet.messageapp.*.id
  security_groups = [aws_security_group.alb.id]
}

resource "aws_alb_listener" "messageapp" {
  load_balancer_arn = aws_alb.messageapp.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.messageapp.id
    type             = "forward"
  }
}

resource "aws_security_group" "alb" {
  description = "controls access to the application ELB"

  vpc_id = aws_vpc.messageapp.id
  name   = "messageapp-alb"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}