/*
Author: Raphael Rabelo de Oliveira
GitHub: https://github.com/rabeloo
*/
/*Alarme de CPU baixa*/
resource "aws_autoscaling_policy" "CpuLowUtilization" {
  name                   = "scale-down-${var.tag_name}"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.AutoScalingGroup.name}"
}

resource "aws_cloudwatch_metric_alarm" "CpuLowUtilization" {
  alarm_name          = "CpuLow-${var.tag_name}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "15"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.AutoScalingGroup.name}"
  }

  alarm_description = "Remove 1 instancia caso o ASG esteja com CPU abaixo de 15% por 10 minutos consecutivos"
  alarm_actions     = ["${aws_autoscaling_policy.CpuLowUtilization.arn}"]
}

/*Alarm de CPU Alta*/
resource "aws_autoscaling_policy" "CpuHighUtilization" {
  name                   = "scale-up-${var.tag_name}"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300 
  autoscaling_group_name = "${aws_autoscaling_group.AutoScalingGroup.name}"
}

resource "aws_cloudwatch_metric_alarm" "CpuHighUtilization" {
  alarm_name          = "CpuHigh-${var.tag_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "45"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.AutoScalingGroup.name}"
  }

  alarm_description = "Adiciona 1 instancia caso o ASG esteja com CPU acima de 45% por 4 minutos."
  alarm_actions     = ["${aws_autoscaling_policy.CpuHighUtilization.arn}"]
}
