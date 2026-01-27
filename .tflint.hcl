config {
  force               = false
  disabled_by_default = false
}

plugin "aws" {
  enabled = true
  version = "0.23.1"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Enabled by default. Check more AWS rules: https://github.com/terraform-linters/tflint-ruleset-aws/blob/master/docs/rules/README.md
rule "aws_instance_invalid_type" {
  enabled = true
}

plugin "terraform" {
    enabled = true
    version = "0.2.0"
    source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}
