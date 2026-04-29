locals {
  # AZs that will get a NAT Gateway:
  #   - per-AZ mode: one per AZ that has both a public and private subnet
  #   - single mode:  just the first AZ
  nat_azs = var.create_nat_gateway ? (
    var.nat_gateway_per_az
    ? slice(local.all_azs, 0, min(var.public_subnet_count, var.private_subnet_count))
    : [local.all_azs[0]]
  ) : []
}

resource "aws_internet_gateway" "this" {
  count  = var.create_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags   = merge(local.resource_tags, { Name = "${var.name}-igw" })
}

resource "aws_eip" "nat" {
  for_each   = toset(local.nat_azs)
  depends_on = [aws_internet_gateway.this]
  tags       = merge(local.resource_tags, { Name = "${var.name}-nat-eip-${each.key}" })
}

resource "aws_nat_gateway" "this" {
  for_each      = toset(local.nat_azs)
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
  tags          = merge(local.resource_tags, { Name = "${var.name}-nat-gateway-${each.key}" })
}
