### Daily budget - actual figure
resource "aws_budgets_budget" "daily_actual_email" {
  name         = "daily-budget-actual"
  budget_type  = "COST"
  limit_amount = "5"
  limit_unit   = "USD"
  time_unit    = "DAILY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 90
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["REPLACE_ME"]
  }
}

### Monthly budget - forecasted figure
resource "aws_budgets_budget" "monthly_forecasted_email" {
  name         = "monthly-budget-forecasted"
  budget_type  = "COST"
  limit_amount = "50"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 90
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = ["REPLACE_ME"]
  }
}

### Monthly budget - actual figure
resource "aws_budgets_budget" "monthly_actual_email" {
  name         = "monthly-budget-actual"
  budget_type  = "COST"
  limit_amount = "50"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["REPLACE_ME"]
  }
}