

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  
  tags = {
    Name = "${var.env_code}-VPC"
  }
}
resource "aws_subnet" "public" {
  count = length(var.public_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_cidr[count.index]
  availability_zone = var.availibilty_zones[count.index]

  tags = {
    Name = "${var.env_code}-public${count.index + 1}"
  }
}
resource "aws_subnet" "private" {
  count = length(var.private_cidr)

  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_cidr[count.index]

  availability_zone = var.availibilty_zones[count.index]

  tags = {
    Name = "${var.env_code}-private${count.index + 1}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env_code}-Gateway"
  }
}

resource "aws_route_table" "r_p" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.env_code}-public_route_table"
  }
}
resource "aws_route_table_association" "a" {
  count = length(var.public_cidr)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.r_p.id
}

resource "aws_eip" "eip" {
  count = length(var.public_cidr)

  vpc = true
  tags = {
    Name = "${var.env_code}-eip${count.index + 1}"
  }

}

resource "aws_nat_gateway" "gwNat" {
  count = length(var.public_cidr)

  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name = "${var.env_code}-nat-gateway${count.index + 1}"
  }

}



resource "aws_route_table" "r_Nat" {

  count = length(var.private_cidr)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gwNat[count.index].id
  }

  tags = {
    Name = "${var.env_code}-private_route_table${count.index + 1}"
  }
}
resource "aws_route_table_association" "a_pr" {
  count = length(var.private_cidr)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.r_Nat[count.index].id
}

