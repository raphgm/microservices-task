output "log_group_name" {
  value = aws_cloudwatch_log_group.frontend_log_group.name
}

output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.frontend_cpu_utilization.alarm_name
}
