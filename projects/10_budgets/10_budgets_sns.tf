data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:StopInstances"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

data "aws_iam_policy_document" "sns" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["budgets.amazonaws.com"]
    }
    actions   = ["SNS:Publish"]
    resources = ["arn:aws:sns:${local.default_region}:${local.account_id}:stop-instances"]
    effect    = "Allow"
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [local.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:budgets::${local.account_id}:*"]
    }
  }
}

### Lambda
module "lambda_stop_instances" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.14.0"

  function_name = "stop-instances"
  handler       = "bootstrap"
  runtime       = "provided.al2023"
  architectures = ["arm64"] # same architecture as the architecture selected during the build/zip process of the lambda function

  # Only build when there is a code change
  trigger_on_package_timestamp = false

  cloudwatch_logs_retention_in_days = 14

  # Generate a 'bootstrap' file from the code and upload it to the Lambda
  source_path = [
    {
      path = "lambda/stopinstances"
      commands = [
        # Exclude RPC package as not required to reduce size; set CGO to 0 as not using libraries in C
        "GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -tags lambda.norpc -o bootstrap main.go",
        ":zip",
      ]
      patterns = [
        "!.*",
        "bootstrap",
      ]
    }
  ]

  allowed_triggers = {
    sns = {
      principal  = "sns.amazonaws.com"
      source_arn = "arn:aws:sns:${local.default_region}:${local.account_id}:*"
    }
  }
  create_current_version_allowed_triggers = false

  attach_policy_json = true
  policy_json        = data.aws_iam_policy_document.lambda.json
}

### SNS
module "sns_stop_instances" {
  source  = "terraform-aws-modules/sns/aws"
  version = "6.1.1"

  name = "stop-instances"

  subscriptions = {
    lambda = {
      protocol = "lambda"
      endpoint = module.lambda_stop_instances.lambda_function_arn
    }
  }

  create_topic_policy         = false
  enable_default_topic_policy = false
  topic_policy                = data.aws_iam_policy_document.sns.json
}

### Monthly budget - actual figure
resource "aws_budgets_budget" "monthly_actual_sns" {
  name         = "monthly-budget-actual-sns"
  budget_type  = "COST"
  limit_amount = "50"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [module.sns_stop_instances.topic_arn]
  }
}