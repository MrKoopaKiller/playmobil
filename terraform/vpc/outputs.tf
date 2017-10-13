/*
Author: Raphael Rabelo de Oliveira
GitHub: https://github.com/rabeloo
*/
/*Saída dos resultados ao final da execução.*/
output "vpc_id" {
  value = "${aws_vpc.main.id}"
}
output "public_subnets" {
  value = "${join(",", aws_subnet.public-subnet.*.id)}"
}
output "private_subnets" {
  value = "${join(",", aws_subnet.private-subnet.*.id)}"
}
output "azs" {
  value = "${lookup(var.azs, var.region)}"
}
