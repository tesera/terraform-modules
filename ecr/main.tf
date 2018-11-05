
resource "aws_ecr_repository" "main" {
  count = "${length(var.ecr)}"
  name = "${var.ecr[count.index]}"
}
