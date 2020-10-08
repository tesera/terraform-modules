locals {
  name          = var.name != "" ? "-${var.name}" : ""
  sse_algorithm = "AES256"
}

