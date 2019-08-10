resource "aws_iam_service_linked_role" "main" {
  aws_service_name = "es.amazonaws.com"
}

