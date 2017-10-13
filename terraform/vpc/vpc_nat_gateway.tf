/*
Author: Raphael Rabelo de Oliveira
GitHub: https://github.com/rabeloo
*/
/*Cria um EIP que será usado pelo NAT gateway*/
resource "aws_eip" "eip_nat" {
  vpc = true
  lifecycle {
    create_before_destroy = true
  }
}
/*Cria um natgateway*/
resource "aws_nat_gateway" "natgw" {
  allocation_id = "${aws_eip.eip_nat.id}"
  subnet_id     = "${element(aws_subnet.public-subnet.*.id, count.index)}"
  lifecycle {
    create_before_destroy = true
  }
}
