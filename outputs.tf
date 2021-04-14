#
# https://www.terraform.io/docs/language/values/outputs.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic#attributes-reference
#
output "sns_topic_arn" {
  value       = aws_sns_topic.root_user_login_attempts.arn
  description = "ARN of the newly minted pub/sub topic"
}