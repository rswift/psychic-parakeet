#
# Define data items that permit the resolution of the account number and region
#
# https://www.terraform.io/docs/providers/aws/d/caller_identity.html
#
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs#shared-credentials-file
variable "aws_profile" {
  default     = "default"
  description = "The name of the AWS profile to use, as per the shared credentials file"
}

#
# Deployment
#
variable "target_account" {
  description = "The AWS account number of the account where the function will be deployed into"
}

variable "region" {
  default     = "us-east-1"
  description = "The region that the root login alert will be deployed into - typically us-east-1"
}

#
# Topic & Subscription
#
variable "name" {
  default     = "RootUserLoginAttempt"
  description = "Name of the SNS topic & EventBridge Rule that will be used for alerting"
}

variable "friendly_name" {
  default     = "Root User Login Attempt"
  description = "Friendly display name"
}

variable "sns_email_subscribers" {
  type = list(string)
  description = "List of email addresses, note the Terraform caveats around unconfirmed subscriptions: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription"

  #
  # It might be worth adding a validation rule in here for a given domain or domains?
  # https://www.terraform.io/docs/language/values/variables.html#custom-validation-rules
  #
}