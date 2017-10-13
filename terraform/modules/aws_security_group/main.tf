/*
Author: Raphael Rabelo de Oliveira
GitHub: https://github.com/rabeloo
*/
/*Modulo que cria security groups.*/
resource "aws_security_group" "secGroup" {
  name = "${var.tag_name}"
  description = "Managed by Terraform"
  vpc_id = "${var.vpc_id}"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
