# Reference the existing SNS topic by ARN
data "aws_sns_topic" "stock_available" {
  name = "stockAvailable"  

} 

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "notify_user-${terraform.workspace}" 
  principal     = "sns.amazonaws.com"
  source_arn    = data.aws_sns_topic.stock_available.arn
}

