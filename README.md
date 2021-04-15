# Introduction
Very simple repo with very simple configuration to create a simple alert for an AWS [root user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-user.html "root user") account login attempt.

## Costs
Running the configuration here could result in charges, albeit modest. But please be aware that this is a possibility before you `terraform apply`!

# Terraform
This has been written using [Terraform](https://learn.hashicorp.com/collections/terraform/aws-get-started "Terraform") `v0.14.10` (see [provider.tf](./provider.tf "provider.tf")) but should work fine with any version from v0.12 onwards.

# AWS
![Architecture](Assets/Architecture.png?raw=true "Architecture")

The resources created are:
* SNS Topic
* Zero or more email subscriptions
* EventBridge Rule

Massage [terraform.tfvars.example](./terraform.tfvars.example "terraform.tfvars.example") and rename as `terraform.tfvars` (or to taste as you prefer).
Obviously the specified `us-east-1` region could be different, but these events [only fire in North Virginia](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/EventTypes.html#console_event_type "AWS Management Console sign-in events can be detected by CloudWatch Events only in the US East (N. Virginia) Region").

# Event Pattern
It shouldn't need it, but the [event pattern](./event_pattern.json "event_pattern.json") can be modified to taste.

# Subscription
The email addresses subscribed in the `terraform.tfvars` file need to be confirmed. If they aren't confirmed and you run `terraform destroy` then they will be left dangling...

# Notification
The email notification has been configured to [transform the data](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-transforming-target-input.html "Input Transform") but it is most definitely functional rather than pretty.