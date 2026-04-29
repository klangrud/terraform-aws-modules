resource "aws_route_table" "public" {
  for_each = local.public_subnets

  vpc_id = aws_vpc.this.id

  tags = merge(local.resource_tags, {
    Name = "${var.name}-public-rt-${each.key}"
  })
}

resource "aws_route" "public_internet" {
  for_each = var.create_internet_gateway ? aws_route_table.public : {}

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "public" {
  for_each       = local.public_subnets
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[each.key].id
}

resource "aws_route_table" "private" {
  for_each = local.private_subnets

  vpc_id = aws_vpc.this.id

  tags = merge(local.resource_tags, {
    Name = "${var.name}-private-rt-${each.key}"
  })
}

resource "aws_route_table_association" "private" {
  for_each = local.private_subnets

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route" "private_internet" {
  for_each = var.create_nat_gateway ? aws_route_table.private : {}

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  # each.key is the AZ of the private subnet's route table.
  # In per-AZ mode, route to the NGW in the same AZ.
  # In single mode, route everything through the one NGW in the first AZ.
  nat_gateway_id = aws_nat_gateway.this[
    var.nat_gateway_per_az ? each.key : local.all_azs[0]
  ].id
}
