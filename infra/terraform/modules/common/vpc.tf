resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags, {
      Tier = var.tier,
    }
  )
}

resource "aws_subnet" "private" {
  for_each          = var.availability_zones
  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 8, 0 + each.value.order)

  tags = merge(
    var.tags, {
      Name = "${var.label}-private-${each.value.id}",
      Tier = var.tier,
    }
  )
}

resource "aws_subnet" "public" {
  for_each          = var.availability_zones
  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 8, 3 + each.value.order)

  tags = merge(
    var.tags, {
      Name = "${var.label}-public-${each.value.id}",
      Tier = var.tier,
    }
  )
}

resource "aws_eip" "nat_gateway" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.label}",
      Tier = var.tier,
    }
  )
}

# コスト削減のため、NAT Gatewayは1つだけ作成する(RDSのマイグレーションでしか現在は使用しない)
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public[var.nat_gateway_subnet].id
  # connectivity_type = "public"

  tags = merge(
    var.tags, {
      Name = "${var.label}-${var.availability_zones[var.nat_gateway_subnet].id}",
      Tier = var.tier,
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(
    var.tags, {
      Name = "${var.label}-private",
      Tier = var.tier,
    }
  )
}

resource "aws_route_table_association" "private" {
  for_each       = var.availability_zones
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private.id
}

# resource "aws_eip" "nat_gateway" {
#   for_each = var.availability_zones
#   vpc      = true

#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.label}-${each.value.id}",
#       Tier = var.tier,
#     }
#   )
# }

# # 全てのサブネットに対して、NAT Gatewayを作成する
# resource "aws_nat_gateway" "this" {
#   for_each      = var.availability_zones
#   allocation_id = aws_eip.nat_gateway[each.key].id
#   subnet_id     = aws_subnet.public[each.key].id

#   tags = merge(
#     var.tags, {
#       Name = "${var.label}-${each.value.id}"
#       Tier = var.tier,
#     }
#   )
# }

# resource "aws_route_table" "private" {
#   for_each = var.availability_zones
#   vpc_id   = aws_vpc.this.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.this[each.key].id
#   }

#   tags = merge(
#     var.tags, {
#       Name = "${var.label}-private-${each.value.id}"
#       Tier = var.tier,
#     }
#   )
# }

# resource "aws_route_table_association" "private" {
#   for_each       = var.availability_zones
#   subnet_id      = aws_subnet.private[each.key].id
#   route_table_id = aws_route_table.private[each.key].id
# }

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags, {
      Tier = var.tier,
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    var.tags, {
      Name = "${var.label}-public"
      Tier = var.tier,
    }
  )
}

resource "aws_route_table_association" "public" {
  for_each       = var.availability_zones
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_flow_log" "this" {
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id               = aws_vpc.this.id
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
}
