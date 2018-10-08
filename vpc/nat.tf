# local.az_count == length(var.public_subnet_ids)
resource "aws_eip" "nat" {
  count = "${local.az_count}"
  vpc   = true

  tags  = "${merge(local.tags, map(
    "Name", "${local.name}-${local.az_name[count.index]}"
  ))}"
}
