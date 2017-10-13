/*
Author: Raphael Rabelo de Oliveira
GitHub: https://github.com/rabeloo
*/

/*Provisiona um autoscaling group*/
resource "aws_autoscaling_group" "AutoScalingGroup" {
  name                 = "asg-${var.tag_name}"
  min_size             = "${var.asg_min_size}"
  max_size             = "${var.asg_max_size}"
  desired_capacity     = "${var.asg_des_size}"
  vpc_zone_identifier  = ["${split(",", data.terraform_remote_state.vpc.private_subnets)}"]
  target_group_arns    = ["${aws_alb_target_group.targetGroup.arn}"]
  launch_configuration = "${aws_launch_configuration.launchConfiguration.name}"
  tag {
    key                 = "Name"
    value               = "${var.tag_name}"
    propagate_at_launch = "true"
  }
  lifecycle {
    create_before_destroy = true
  }
}
