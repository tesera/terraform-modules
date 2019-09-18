resource "aws_vpc" "main" {
  cidr_block                       = local.cidr_block
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true

  tags = merge(
    local.tags,
    {
      Name = local.name
    }
  )
}

# IPv4
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.tags,
    {
      Name = local.name
    }
  )
}

# IPv6
resource "aws_egress_only_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Override defaults
resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-default"
    }
  )
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-default"
    }
  )
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-default"
    }
  )
}

# Logs
resource "aws_flow_log" "logs" {
  log_destination = aws_cloudwatch_log_group.logs.arn
  iam_role_arn    = aws_iam_role.logs.arn
  vpc_id          = aws_vpc.main.id
  traffic_type    = "ALL"
}

resource "aws_cloudwatch_log_group" "logs" {
  name = "/${aws_vpc.main.id}"
}

resource "aws_iam_role" "logs" {
  name = "${local.name}-vpc-logs-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "logs" {
  name = "${local.name}-vpc-logs-policy"
  role = aws_iam_role.logs.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}

