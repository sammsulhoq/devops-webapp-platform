data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "management" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "hv-capstone-management-vpc"
  }
}

resource "aws_subnet" "management_public" {
  vpc_id                  = aws_vpc.management.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "hv-capstone-management-public"
  }
}

resource "aws_internet_gateway" "management" {
  vpc_id = aws_vpc.management.id

  tags = {
    Name = "hv-capstone-management-igw"
  }
}

resource "aws_route_table" "management_public" {
  vpc_id = aws_vpc.management.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.management.id
  }

  tags = {
    Name = "hv-capstone-management-public"
  }
}

resource "aws_route_table_association" "management_public" {
  subnet_id      = aws_subnet.management_public.id
  route_table_id = aws_route_table.management_public.id
}
