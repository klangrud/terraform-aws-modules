# locals {
#   vpc_endpoint_map = {
#     for svc in var.vpc_endpoints : svc => {}
#   }
# }

# resource "aws_vpc_endpoint" "this" {
#   for_each = local.vpc_endpoint_map
#
#   vpc_id            = aws_vpc.this.id
#   service_name      = "com.amazonaws.${var.region}.${each.key}"
#
#   vpc_endpoint_type = contains(["s3", "dynamodb"], each.key) ? "Gateway" : "Interface"
#   route_table_ids   = contains(["s3", "dynamodb"], each.key) ? [for rt in aws_route_table.public : rt.id] : null
#   subnet_ids        = contains(["s3", "dynamodb"], each.key) ? null : [for s in aws_subnet.private : s.id]
#   security_group_ids = contains(["s3", "dynamodb"], each.key) ? null : [aws_security_group.vpc_endpoints.id]
#
#
#   private_dns_enabled = contains(["s3", "dynamodb"], each.key) ? false : true
#
#   tags = merge(local.resource_tags, {
#     Name          = "${var.name}-endpoint-${each.key}"
#     TestResource  = var.test_resource_tag
#   })
# }

resource "aws_vpc_endpoint" "this" {
  for_each = { for svc in var.vpc_endpoints : svc => svc }

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type = each.key == "s3" || each.key == "dynamodb" ? "Gateway" : "Interface"

  subnet_ids         = each.key == "s3" || each.key == "dynamodb" ? null : values(aws_subnet.private)[*].id
  route_table_ids    = each.key == "s3" || each.key == "dynamodb" ? [for rt in aws_route_table.private : rt.id] : null
  security_group_ids = each.key == "s3" || each.key == "dynamodb" ? null : [aws_security_group.private.id]

  private_dns_enabled = each.key == "s3" || each.key == "dynamodb" ? false : true

  tags = merge(local.resource_tags, {
    Name         = "${var.name}-endpoint-${each.key}"
    TestResource = var.test_resource_tag
  })
}
