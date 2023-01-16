resource "aws_vpc" "main" {
  cidr_block       = "192.168.0.0/16"
  
  tags = {
    Name = "myVPC"
  }
}
resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.0.0/24"
  availability_zone="us-west-2a" 

  tags = {
    Name = "public1"
  }
}
resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.1.0/24"
  availability_zone="us-west-2a" 

  tags = {
    Name = "private1"
  }
}
resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.2.0/24"
  availability_zone="us-west-2b" 

  tags = {
    Name = "public2"
  }
}
resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.3.0/24"
  availability_zone="us-west-2b" 

  tags = {
    Name = "private2"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "myGateway"
  }
}
resource "aws_route_table" "r_p" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

    tags = {
    Name = "public_route_table"
  }
}
resource "aws_route_table_association" "a1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.r_p.id
}
resource "aws_route_table_association" "a2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.r_p.id
}
resource "aws_eip" "eip1" {
  vpc = true
}
resource "aws_eip" "eip2" {
  vpc = true
}
resource "aws_nat_gateway" "gwNat1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public1.id
}
resource "aws_nat_gateway" "gwNat2" {
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.public2.id
}

resource "aws_route_table" "r_Nat1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gwNat1.id
  }

    tags = {
    Name = "private1_route_table"
  }
}
resource "aws_route_table_association" "a_pr1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.r_Nat1.id
}
resource "aws_route_table" "r_Nat2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gwNat2.id
  }

    tags = {
    Name = "private2_route_table"
  }
}
resource "aws_route_table_association" "a_pr2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.r_Nat2.id
}