module "defaults" {
  source = "../defaults"
  name   = "${var.name}"
  tags   = "${var.default_tags}"
}

locals {
  region        = "${module.defaults.region}"
  tags          = "${module.defaults.tags}"
  name          = "${module.defaults.name}"
  sse_algorithm = "AES256"

  lambda_viewer_request_enabled = "${(var.lambda_viewer_request_default || var.lambda_viewer_request != "")}"
  lambda_origin_request_enabled = "${(var.lambda_origin_request_default || var.lambda_origin_request != "")}"
  lambda_viewer_response_enabled = "${(var.lambda_viewer_response_default || var.lambda_viewer_response != "")}"
  lambda_origin_response_enabled = "${(var.lambda_origin_response_default || var.lambda_origin_response != "")}"
}
