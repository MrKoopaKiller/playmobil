/*
Author: Raphael Rabelo de Oliveira
GitHub: https://github.com/rabeloo
*/

/*Cria um security group a ser usado na instancias criadas pelo autoscaling group*/
module "instances_sg" {
  source   = "../modules/aws_security_group"
  vpc_id   = "${data.terraform_remote_state.vpc.vpc_id}"
  tag_name = "SG-${var.tag_name}"
}
/*Cria um security group a ser usado ALB*/
module "loadbalancer_sg" {
  source   = "../modules/aws_security_group"
  vpc_id   = "${data.terraform_remote_state.vpc.vpc_id}"
  tag_name = "SG-ALB-${var.tag_name}"
}
/*Cria uma regra permitindo acesso de qualquer source ao ALB na porta configurada.*/
resource "aws_security_group_rule" "allow_connections_to_alb" {
  type              = "ingress"
  from_port         = "${var.alb_listen_port}"
  to_port           = "${var.alb_listen_port}"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${module.loadbalancer_sg.sg_id}"
  lifecycle {
    create_before_destroy = true
  }
}
/*Cria uma regra no security group das instancias permitindo acesso apenas ao ALB na porta configurada*/
resource "aws_security_group_rule" "allow_connections_from_alb" {
  type                     = "ingress"
  from_port                = "${var.app_listen_port}"
  to_port                  = "${var.app_listen_port}"
  protocol                 = "tcp"
  source_security_group_id = "${module.loadbalancer_sg.sg_id}"
  security_group_id        = "${module.instances_sg.sg_id}"
  lifecycle {
    create_before_destroy = true
  }
}
