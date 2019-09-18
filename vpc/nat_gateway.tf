# gateway
resource "aws_route_table" "private-gateway" {
  count  = var.nat_type == "gateway" ? local.az_count : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public[count.index].id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.main.id
  }

  tags = merge(
    local.tags,
    {
      Name = "private-${local.name}-${local.az_name[count.index]}"
    }
  )
}

resource "aws_route_table_association" "private-gateway" {
  count          = var.nat_type == "gateway" ? local.az_count : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private-gateway[count.index].id
}

# gateway
resource "aws_nat_gateway" "public" {
  count         = var.nat_type == "gateway" ? local.az_count : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-nat-${local.az_name[count.index]}"
    }
  )
}

