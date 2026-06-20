resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "kafka-vpc"
    Environment = var.environment
    Project     = "Kafka-Infrastructure-Platform"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "kafka-igw"
    Environment = var.environment
    Project     = "Kafka-Infrastructure-Platform"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones[0]

  tags = {
    Name        = "kafka-public-subnet"
    Environment = var.environment
    Project     = "Kafka-Infrastructure-Platform"
  }
}

resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "kafka-private-subnet-0${count.index + 1}"
    Environment = var.environment
    Project     = "Kafka-Infrastructure-Platform"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "kafka-nat-eip"
    Environment = var.environment
    Project     = "Kafka-Infrastructure-Platform"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name        = "kafka-nat-gw"
    Environment = var.environment
    Project     = "Kafka-Infrastructure-Platform"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "kafka-public-rt"
    Environment = var.environment
    Project     = "Kafka-Infrastructure-Platform"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name        = "kafka-private-rt"
    Environment = var.environment
    Project     = "Kafka-Infrastructure-Platform"
  }
}

resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
