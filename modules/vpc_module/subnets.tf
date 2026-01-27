# subnets.tf
locals {
  # Get AZs from either mock_azs (for testing) or the data source (for real deployments)
  raw_azs = var.mock_azs != null ? var.mock_azs : data.aws_availability_zones.available[0].names

  # Load all AZs in alphabetical order (a-f), so indexing is predictable
  all_azs = sort([
    for az in local.raw_azs : az
    if can(regex("[a-f]$", az))
  ])

  public_azs  = slice(local.all_azs, 0, var.public_subnet_count)
  private_azs = slice(local.all_azs, 0, var.private_subnet_count)
  rds_azs     = slice(local.all_azs, 0, var.rds_subnet_count)

  # ============================================================================
  # Dynamic CIDR Calculation
  # ============================================================================
  # Extract VPC prefix length (e.g., 16 from "10.0.0.0/16")
  vpc_prefix_length = tonumber(split("/", var.vpc_cidr)[1])

  # Maximum newbits to keep subnets at /28 or larger (AWS minimum subnet size)
  max_newbits = 28 - local.vpc_prefix_length

  # Public/Private subnets: prefer larger subnets (newbits=4 gives /20 for /16 VPC)
  # Cap at max_newbits to ensure subnets don't go below /28
  public_private_newbits = min(4, local.max_newbits)

  # RDS/Custom subnets: prefer smaller subnets (newbits=8 gives /24 for /16 VPC)
  # Cap at max_newbits to ensure subnets don't go below /28
  rds_custom_newbits = min(8, local.max_newbits)

  # Private subnet start index (leaves room for up to 6 public subnets)
  private_start_index = 6

  # RDS/Custom index calculation:
  # - For large VPCs (/16-/20): use high indices (198, 200) to keep addresses separate
  # - For small VPCs (/21-/24): use indices after public/private since we have fewer slots
  use_high_indices = local.rds_custom_newbits >= 8

  # When using low indices, start after private subnets (index 12+)
  rds_start_index    = local.use_high_indices ? 200 : 12
  custom_start_index = local.use_high_indices ? 198 : (local.rds_start_index + var.rds_subnet_count)

  custom_subnet_block_size = 6 # Space each custom subnet block 6 subnets apart

  # ============================================================================
  # Subnet Definitions
  # ============================================================================
  custom_subnets = merge({
    for idx, custom_subnet in var.custom_subnets :
    custom_subnet.name => tomap({
      for az_idx in range(custom_subnet.subnet_count) :
      local.all_azs[az_idx] => {
        cidr_block = cidrsubnet(
          var.vpc_cidr,
          local.rds_custom_newbits,
          local.custom_start_index + (idx * local.custom_subnet_block_size) + az_idx
        )
        az     = local.all_azs[az_idx]
        public = custom_subnet.public
      }
    })
  })

  flattened_custom_subnets = merge([
    for name, azs in local.custom_subnets : {
      for az, config in azs : "${name}-${az}" => {
        name       = name
        az         = az
        cidr_block = config.cidr_block
        public     = config.public
      }
    }
  ]...)

  public_subnets = tomap({
    for idx, az in local.public_azs :
    az => {
      cidr_block = cidrsubnet(var.vpc_cidr, local.public_private_newbits, idx)
      az         = az
    }
  })

  private_subnets = tomap({
    for idx, az in local.private_azs :
    az => {
      cidr_block = cidrsubnet(var.vpc_cidr, local.public_private_newbits, idx + local.private_start_index)
      az         = az
    }
  })

  rds_subnets = var.create_rds_subnets ? tomap({
    for idx, az in local.rds_azs :
    az => {
      cidr_block = cidrsubnet(var.vpc_cidr, local.rds_custom_newbits, local.rds_start_index + idx)
      az         = az
    }
  }) : {}
}

resource "aws_subnet" "public" {
  for_each          = local.public_subnets
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = merge(local.resource_tags, {
    Name = "${var.name}-public-subnet-${each.key}"
  })
}

resource "aws_subnet" "private" {
  for_each          = local.private_subnets
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = merge(local.resource_tags, {
    Name = "${var.name}-private-subnet-${each.key}"
  })
}

resource "aws_subnet" "rds" {
  for_each          = var.create_rds_subnets ? local.rds_subnets : {}
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = merge(local.resource_tags, {
    Name = "${var.name}-rds-subnet-${each.key}"
  })
}

resource "aws_subnet" "custom_subnet" {
  for_each = var.additional_custom_subnets

  vpc_id     = aws_vpc.this.id
  cidr_block = each.value.cidr_block
  availability_zone = local.raw_azs[
    index(keys(var.additional_custom_subnets), each.key) % length(local.raw_azs)
  ]

  tags = merge(
    var.tags,
    {
      Name = each.key
      Type = each.value.type
    }
  )
}
