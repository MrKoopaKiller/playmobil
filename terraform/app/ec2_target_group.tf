/*
Author: Raphael Rabelo de Oliveira
GitHub: https://github.com/rabeloo
*/
/*Provisiona um target group usado pelo ALB*/
resource "aws_alb_target_group" "targetGroup"{
  name = "tg-${var.tag_name}"
  port = "${var.app_listen_port}"
  protocol = "HTTP"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  health_check = {
    interval = "${var.hc_interval}"
    path = "${var.hc_path}"
    port = "${var.hc_port}"
    protocol = "${var.hc_protocol}"
    timeout = "${var.hc_timeout}"
    unhealthy_threshold = "${var.hc_unhealthy_threshold}"
    matcher = "${var.hc_matcher}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

