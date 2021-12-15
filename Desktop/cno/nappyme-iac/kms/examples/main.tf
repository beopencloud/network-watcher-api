data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid    = "1"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }
    actions = [
      "kms:*",
    ]
    resources = [
      "*",
    ]
  }
}


module "kms" {
  source                  = "../"
  aws_region              = "eu-west-1" 
  deletion_window_in_days = 30
  environment             = "dev"
  alias_name              = "secret-parameter"
  key_policy              = data.aws_iam_policy_document.kms_key_policy.json
}