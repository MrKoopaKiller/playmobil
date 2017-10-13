/*
Author: Raphael Rabelo de Oliveira
GitHub: https://github.com/rabeloo
*/

/*Provisiona ALB na rede pública*/
resource "aws_alb" "loadBalancer" {
  name = "alb-${var.tag_name}"
  internal = false
  security_groups = ["${module.loadbalancer_sg.sg_id}"]
  subnets = ["${split(",", data.terraform_remote_state.vpc.public_subnets)}"]
  enable_deletion_protection = false
  lifecycle {
    create_before_destroy = true
  }
}
/*Criar um listener na porta definida para o ALB criado acima*/
resource "aws_alb_listener" "albListeners" {
  load_balancer_arn = "${aws_alb.loadBalancer.arn}"
  port = "${var.alb_listen_port}"
  protocol = "HTTP"
  default_action {
    target_group_arn = "${aws_alb_target_group.targetGroup.arn}"
    type = "forward"
  }
  lifecycle {
    create_before_destroy = true
  }
}
