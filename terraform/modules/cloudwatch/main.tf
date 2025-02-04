/*resource "aws_cloudwatch_log_group" "ec2_logs" {
  name              = "/aws/ec2/logs"
  retention_in_days = 7

  tags = {
    Name        = "EC2Logs"
    Environment = var.env_prefix
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "HighCPUUsage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm is triggered when CPU utilization exceeds 80%."
  dimensions = {
    InstanceId = var.monitored_instance_ids[0]
  }

  tags = {
    Environment = var.env_prefix
  }
}*/




##########################
# CloudWatch Monitoring   #
##########################

# CloudWatch Log Group for Frontend EC2
resource "aws_cloudwatch_log_group" "frontend_log_group" {
  name = "/aws/ec2/frontend/logs"
}

# CloudWatch Log Group for Backend EC2
resource "aws_cloudwatch_log_group" "backend_log_group" {
  name = "/aws/ec2/backend/logs"
}

# CloudWatch Log Group for Jenkins EC2
resource "aws_cloudwatch_log_group" "jenkins_log_group" {
  name = "/aws/ec2/jenkins/logs"
}

# CloudWatch Log Group for RDS
resource "aws_cloudwatch_log_group" "rds_log_group" {
  name = "/aws/rds/logs"
}



# CloudWatch Alarm for Frontend EC2 CPU Utilization
resource "aws_cloudwatch_metric_alarm" "frontend_cpu_utilization" {
  alarm_name          = "frontend-cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alarm if CPU utilization of the frontend instance exceeds 80%"
  dimensions = {
    #frontend_instance_id = module.ec2_instance.frontend_instance_id
    InstanceId = var.frontend_instance_id

    #InstanceId = module.ec2_instance.frontend-instance
    #monitored_instance_ids = [module.ec2_instance.frontend-instance.instance_id]
  }
  actions_enabled = true
}


# CloudWatch Alarm for Backend EC2 CPU Utilization
resource "aws_cloudwatch_metric_alarm" "backend_cpu_utilization" {
  alarm_name          = "backend-cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alarm if CPU utilization of the backend instance exceeds 80%"
  dimensions = {
    InstanceId = var.backend_instance_id
  }
  actions_enabled = true
}

# CloudWatch Alarm for Jenkins EC2 CPU Utilization
resource "aws_cloudwatch_metric_alarm" "jenkins_cpu_utilization" {
  alarm_name          = "jenkins-cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alarm if CPU utilization of the Jenkins instance exceeds 80%"
  dimensions = {
    InstanceId = var.jenkins_instance_id
  }
  actions_enabled = true
}

# CloudWatch Alarm for RDS CPU Utilization
resource "aws_cloudwatch_metric_alarm" "rds_cpu_utilization" {
  alarm_name          = "rds-cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alarm if RDS CPU utilization exceeds 80%"
  dimensions = {
    #DBInstanceIdentifier = var.DBInstanceIdentifier
    DBInstanceIdentifier = var.rds_instance_id
  }
  actions_enabled = true
}

# CloudWatch Log Subscription for Frontend Instance Logs
/*resource "aws_cloudwatch_log_subscription_filter" "frontend_log_subscription" {
  name            = "frontend-log-subscription"
  log_group_name  = aws_cloudwatch_log_group.frontend_log_group.name
  filter_pattern  = ""
  destination_arn = "arn:aws:sns:us-west-2:123456789012:MyTopic" # Example SNS topic ARN for notifications
}

# CloudWatch Log Subscription for Backend Instance Logs
resource "aws_cloudwatch_log_subscription_filter" "backend_log_subscription" {
  name            = "backend-log-subscription"
  log_group_name  = aws_cloudwatch_log_group.backend_log_group.name
  filter_pattern  = ""
  destination_arn = "arn:aws:sns:us-west-2:123456789012:MyTopic"
}

# CloudWatch Log Subscription for Jenkins Instance Logs
resource "aws_cloudwatch_log_subscription_filter" "jenkins_log_subscription" {
  name            = "jenkins-log-subscription"
  log_group_name  = aws_cloudwatch_log_group.jenkins_log_group.name
  filter_pattern  = ""
  destination_arn = "arn:aws:sns:us-west-2:123456789012:MyTopic"
}

# CloudWatch Log Subscription for RDS Logs
resource "aws_cloudwatch_log_subscription_filter" "rds_log_subscription" {
  name            = "rds-log-subscription"
  log_group_name  = aws_cloudwatch_log_group.rds_log_group.name
  filter_pattern  = ""
  destination_arn = "arn:aws:sns:us-west-2:123456789012:MyTopic"
}*/
