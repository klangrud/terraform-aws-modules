# Common ingress/egress rules - customize as needed
locals {
  common_egress_rule = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }]

  rds_ingress_sources = var.create_rds_subnets ? concat(
    values(local.private_subnets)[*].cidr_block,
    [
      for entry in local.flattened_custom_subnets :
      entry.cidr_block if entry.public == false
    ]
  ) : []

}

resource "aws_security_group" "default" {
  vpc_id = aws_vpc.this.id
  name   = "${var.name}-default-sg"
  tags   = merge(local.resource_tags, { Name = "${var.name}-default-sg" })

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.name}-vpc-endpoints-sg"
  description = "Security group for interface-style VPC endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow all inbound from within VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.resource_tags, {
    Name = "${var.name}-vpc-endpoints-sg"
  })
}



# Public Subnet Security Group
resource "aws_security_group" "public" {
  name        = "${var.name}-public-sg"
  description = "Security group for public subnets"
  vpc_id      = aws_vpc.this.id

  dynamic "egress" {
    for_each = local.common_egress_rule
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH from trusted IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Prefer to restrict to your bastion or VPN IPs
  }

  ingress {
    description = "Allow ICMP (ping)"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.resource_tags, { Name = "${var.name}-public-sg" })
}

# Private Subnet Security Group
resource "aws_security_group" "private" {
  name        = "${var.name}-private-sg"
  description = "Security group for private subnets"
  vpc_id      = aws_vpc.this.id

  dynamic "egress" {
    for_each = local.common_egress_rule
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  ingress {
    description = "Allow internal traffic from VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }


  tags = merge(local.resource_tags, { Name = "${var.name}-private-sg" })
}

# RDS Subnet Security Group
resource "aws_security_group" "rds" {
  count = var.create_rds_subnets ? 1 : 0

  name        = "${var.name}-rds-sg"
  description = "Security group for RDS access"
  vpc_id      = aws_vpc.this.id
  tags        = merge(local.resource_tags, { Name = "${var.name}-rds-sg" })

  dynamic "ingress" {
    for_each = local.rds_ingress_sources
    content {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  dynamic "ingress" {
    for_each = local.rds_ingress_sources
    content {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  dynamic "ingress" {
    for_each = local.rds_ingress_sources
    content {
      from_port   = 33060
      to_port     = 33060
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Custom Subnet Security Groups (1 per custom subnet group)
resource "aws_security_group" "custom" {
  for_each    = { for subnet in var.custom_subnets : subnet.name => subnet }
  name        = "${var.name}-custom-${each.key}-sg"
  description = "Security group for custom subnet group ${each.key}"
  vpc_id      = aws_vpc.this.id

  dynamic "egress" {
    for_each = local.common_egress_rule
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  ingress {
    description = "Allow internal service-to-service traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge(local.resource_tags, {
    Name = "${var.name}-custom-${each.key}-sg"
  })
}
