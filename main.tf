locals{
 vpc_cidr="192.168.0.0/16"
 public_cidr=["192.168.0.0/24","192.168.1.0/24"]
 private_cidr=["192.168.2.0/24","192.168.3.0/24"]
 availibilty_zones=["us-west-2a","us-west-2b"]

}


resource "aws_vpc" "main" {
  cidr_block       = local.vpc_cidr
  
  tags = {
    Name = "myVPC"
  }
}
resource "aws_subnet" "public" {
  count=length(local.public_cidr)

  vpc_id     = aws_vpc.main.id
  cidr_block = local.public_cidr[count.index]
  availability_zone=local.availibilty_zones[count.index]

  tags = {
    Name = "public${count.index+1}"
  }
}
resource "aws_subnet" "private" {
  count=length(local.private_cidr)

  vpc_id     = aws_vpc.main.id
  cidr_block = local.private_cidr[count.index]

  availability_zone=local.availibilty_zones[count.index]

  tags = {
    Name = "private${count.index+1}"
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
resource "aws_route_table_association" "a" {
  count=length(local.public_cidr)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.r_p.id
}

resource "aws_eip" "eip" {
  count=length(local.public_cidr)

  vpc = true

  
}

resource "aws_nat_gateway" "gwNat" {
  count=length(local.public_cidr)

  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  
}



resource "aws_route_table" "r_Nat" {

  count=length(local.private_cidr)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gwNat[count.index].id
  }

    tags = {
    Name = "private_route_table${count.index+1}"
  }
}
resource "aws_route_table_association" "a_pr" {
  count=length(local.private_cidr)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.r_Nat[count.index].id
}

