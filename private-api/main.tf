
//// S3 & SQS
module "pre_sls" {
    source         = "../pre-sls"
    aws_account_id = "${var.aws_account_id}"
    aws_region     = "${var.aws_region}"
    env_name       = "emis-registration-${var.env}"
}

// lambda permissions
module "post_sls" {
    source         = "../post-sls"
    aws_account_id = "${var.aws_account_id}"
    aws_region     = "${var.aws_region}"
    env_name       = "emis-registration-${var.env}"
}
