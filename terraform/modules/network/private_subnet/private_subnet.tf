variable "name"            { default = "private"}
variable "vpc_id"          { }
variable "cidrs"           { }
variable "azs"             { }
variable "nat_gateway_id" { }

resource "aws_subnet" "private" {
  vpc_id            = var.vpc_id
  cidr_block        = element(split(",", var.cidrs), count.index)
  availability_zone = element(split(",", var.azs), count.index)
  count             = length(split(",", var.cidrs))

  tags = { Name = "${var.name}.${element(split(",", var.azs), count.index)}" }
  lifecycle { create_before_destroy = true }
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_id
  }

  tags = { Name = var.name }
  lifecycle { create_before_destroy = true }
}

resource "aws_route_table_association" "private" {
  count          = length(split(",", var.cidrs))
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)

  lifecycle { create_before_destroy = true }
}

output "subnet_ids"     { value = join(",", aws_subnet.private.*.id) }
output "route_table_id" { value = aws_route_table.private.id }