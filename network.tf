# zones in the current region
data "aws_availability_zones" "available" {}

resource "aws_vpc" "grafana" {
  cidr_block = "172.17.0.0/16"
}

# Create var.az_count private subnets, each in a different AZ
resource "aws_subnet" "grafana-private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.grafana.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.grafana.id
}

# same for public
resource "aws_subnet" "grafana-public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.grafana.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.grafana.id
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "grafana-public" {
  vpc_id = aws_vpc.grafana.id
}

# public subnet traffic through the gateway
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.grafana.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.grafana-public.id
}

# NAT gateway with an Elastic IP for each private subnet to get internet connectivity
resource "aws_eip" "grafana-gw" {
  count      = var.az_count
  domain     = "vpc"
  depends_on = [aws_internet_gateway.grafana-public]
}

resource "aws_nat_gateway" "grafana-gw" {
  count         = var.az_count
  subnet_id     = element(aws_subnet.grafana-public.*.id, count.index)
  allocation_id = element(aws_eip.grafana-gw.*.id, count.index)
}

# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.grafana.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.grafana-gw.*.id, count.index)
  }
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.grafana-private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}
