resource "aws_vpc" "stoic_eks_vpc" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "pub_sub" {
  count                   = length(var.pub_sub)
  vpc_id                  = aws_vpc.stoic_eks_vpc.id
  cidr_block              = var.pub_sub[count.index]
  map_public_ip_on_launch = true
  availability_zone       = element(var.availability_zones, count.index)
}

resource "aws_subnet" "pri_sub" {
  count                   = length(var.pri_sub)
  vpc_id                  = aws_vpc.stoic_eks_vpc.id
  cidr_block              = var.pri_sub[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false
}

resource "aws_security_group" "main_sg" {
  name   = "main_sg"
  vpc_id = aws_vpc.stoic_eks_vpc.id

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes API access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.stoic_eks_vpc.id
}

resource "aws_eip" "nat" {}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.pub_sub[0].id
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.stoic_eks_vpc.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.pub_sub)
  subnet_id      = aws_subnet.pub_sub[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.stoic_eks_vpc.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.pri_sub)
  subnet_id      = aws_subnet.pri_sub[count.index].id
  route_table_id = aws_route_table.private.id
}