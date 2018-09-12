# local.az_count == length(var.public_subnet_ids)
resource "aws_eip" "nat" {
  count = "${local.az_count}"
  vpc   = true

  tags {
    Name      = "${var.name}-az-${local.az_name[count.index]}"
    Terraform = "true"
  }
}
