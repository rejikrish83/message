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

resource "aws_internet_gateway" "messageapp" {
  vpc_id = aws_vpc.messageapp.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.messageapp.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.messageapp.id
  }
}



