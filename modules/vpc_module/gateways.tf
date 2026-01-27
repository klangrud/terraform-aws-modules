resource "aws_internet_gateway" "this" {
  count  = var.create_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags   = merge(local.resource_tags, { Name = "${var.name}-igw" })
}

resource "aws_nat_gateway" "this" {
  count         = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[local.all_azs[0]].id
  tags          = merge(local.resource_tags, { Name = "${var.name}-nat-gateway" })
}

resource "aws_eip" "nat" {
  count      = var.create_nat_gateway ? 1 : 0
  depends_on = [aws_internet_gateway.this]
  tags       = merge(local.resource_tags, { Name = "${var.name}-nat-eip" })
}
