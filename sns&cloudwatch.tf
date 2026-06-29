resource "aws_sns_topic" "alerts" {

  name = "Production-Alerts"

}

resource "aws_sns_topic_subscription" "email" {

  topic_arn = aws_sns_topic.alerts.arn

  protocol = "email"

  endpoint = var.email

}

resource "aws_cloudwatch_metric_alarm" "cpu" {

  alarm_name = "HighCPU"

  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 1

  metric_name = "CPUUtilization"

  namespace = "AWS/EC2"

  period = 300

  statistic = "Average"

  threshold = 80

  alarm_actions = [
      aws_sns_topic.alerts.arn
  ]

  dimensions = {

    InstanceId = aws_instance.ec2.id

  }

}