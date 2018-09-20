data "archive_file" "secrets_manager_lambda" {
  type        = "zip"
  output_path = "./secrets-manager-lambda.zip"
  source_dir  = "${path.module}/secrets-manager-lambda"
}

resource "aws_lambda_function" "rotate_rds" {
  function_name    = "${local.identifier}-secrets-manager-rds"
  filename         = "${data.archive_file.secrets_manager_lambda.output_path}"
  source_code_hash = "${data.archive_file.secrets_manager_lambda.output_base64sha256}"
  role             = "${aws_iam_role.lambda_secrets_manager.arn}"
  handler          = "index.handler"
  runtime          = "python2.7"
  memory_size      = 128
  timeout          = 30
  publish          = true

  environment {
    variables = {
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.ca-central-1.amazonaws.com"
    }
  }

  vpc_config {
    security_group_ids = ["${aws_security_group.main.id}"]
    subnet_ids         = ["${var.private_subnet_ids}"]
  }
}

resource "aws_lambda_permission" "allow_secrets_manager" {
  statement_id  = "AllowExecutionFromSecretsManager"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.rotate_rds.function_name}"
  principal     = "secretsmanager.amazonaws.com"

  #source_arn     = "arn:aws:events:eu-west-1:111122223333:rule/RunDaily"
  #qualifier      = "${aws_lambda_alias.test_alias.name}"
}

resource "aws_iam_role" "lambda_secrets_manager" {
  name = "${local.identifier}-lambda-secrets-manager-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "lambda_secrets_manager" {
  statement {
    sid = "1"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DetachNetworkInterface",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage",
    ]

    resources = [
      "arn:aws:secretsmanager:*",
    ]

    # condition {
    #   test     = "StringEquals"
    #   variable = "secretsmanager:resource/AllowRotationLambdaArn"
    #   values   = ["${aws_lambda_function.rotate_rds.arn}"]
    # }
  }

  statement {
    actions = [
      "secretsmanager:GetRandomPassword",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "lambda_secrets_manager" {
  name   = "${local.identifier}-lambda-secrets-manager-policy"
  path   = "/"
  policy = "${data.aws_iam_policy_document.lambda_secrets_manager.json}"
}

resource "aws_iam_role_policy_attachment" "lambda_secrets_manager" {
  role       = "${aws_iam_role.lambda_secrets_manager.name}"
  policy_arn = "${aws_iam_policy.lambda_secrets_manager.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = "${aws_iam_role.lambda_secrets_manager.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_secretsmanager_secret" "rds_rotation" {
  name = "${local.identifier}-rds-rotation"

  # policy = <<EOF
  # {
  #   "username": "kiril",
  #   "password": "SomePassword123",
  #   "engine": "postgres",
  #   "host": "kiril-rds-postgres.cgjh2wbcrnaa.ca-central-1.rds.amazonaws.com",
  #   "port": 5432,
  #   "dbname": "pg1",
  #   "dbInstanceIdentifier": "kiril-rds-postgres" 
  # }
  # EOF

  rotation_lambda_arn = "${aws_lambda_function.rotate_rds.arn}"
  rotation_rules {
    automatically_after_days = 7
  }
}

resource "aws_security_group" "lambda_rds_rotate" {
  name        = "${local.identifier}-lambda-rds-rotate"
  description = "SecurityGroup for ${local.identifier}-lambda-rds-rotate Lambda."
  vpc_id      = "${var.vpc_id}"

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "lambda_rds_rotate" {
  security_group_id        = "${aws_security_group.main.id}"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.lambda_rds_rotate.id}"
}
