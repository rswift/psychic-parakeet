#
# Define an SNS topic with subscription(s) and an EventBridge Rule (for attempted
# logins with the root user credentials) that has the topic as its target
#
locals {
  cost_allocation = "work"
}

#
# Create a new SNS topic...
#
# The policy is created after the topic is created because the EventBridge rule

#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic
#
resource "aws_sns_topic" "root_user_login_attempts" {
  name         = var.name
  display_name = var.friendly_name

  #
  # KMS only really makes sense if behaviour other than sending an email (which is
  # quite obviously inherently insecure) is used, in this case, keeping it simple...
  #
#  kms_master_key_id = 

  policy = data.aws_iam_policy_document.sns_topic_policy.json

  tags = {
    Name              = var.friendly_name
    "cost:allocation" = local.cost_allocation
  }
}

#
# Create an email subscription or subscriptions...
#
# Be aware that a terraform destroy before the subscription is confirmed will
# leave the subscription dangling, but the Internet seems to suggest they'll
# be removed after 72 hours?
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription
#
resource "aws_sns_topic_subscription" "root_login_attempts_email" {
  count = length(var.sns_email_subscribers)

  topic_arn = aws_sns_topic.root_user_login_attempts.arn
  protocol  = "email"
  endpoint  = element(var.sns_email_subscribers, count.index)
}

#
# Permit EventBridge to publish to the topic 
#
data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    sid     = "AllowEventBridgeToPublish"
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = ["arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:${var.name}"]
  }
}

#
# Create the EventBridge Rule
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule
#
resource "aws_cloudwatch_event_rule" "root_login_attempts" {
  name        = var.name
  description = "Report whenever an attempt is made to log in with the root user"

  event_pattern = data.local_file.event_pattern.content

  tags = {
    Name              = var.friendly_name
    "cost:allocation" = local.cost_allocation
  }
}

data "local_file" "event_pattern" {
    filename = "${path.module}/event_pattern.json"
}

#
# Target is the SNS topic
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target
#
resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.root_login_attempts.name
  target_id = "AlertViaSNS"
  arn       = aws_sns_topic.root_user_login_attempts.arn

  input_transformer {
    input_paths = {
      arn = "$.detail.userIdentity.arn"
      outcome = "$.detail.responseElements.ConsoleLogin"
      sourceIP = "$.detail.sourceIPAddress"
      type = "$.detail.userIdentity.type"
      when = "$.detail.eventTime"
    }

    #
    # It doesn't look pretty, but AWS gives what AWS gives...
    # https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-transforming-target-input.html
    #
    input_template = <<EOT
{
  "login" : <type>,
  "via": <arn>,
  "at" : <when>,
  "from" : <sourceIP>,

  "outcome": <outcome>,

  "event data":
<aws.events.event.json>
}
EOT
  }
}
