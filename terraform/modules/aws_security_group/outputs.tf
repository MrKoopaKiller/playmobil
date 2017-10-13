/*
Author: Raphael Rabelo de Oliveira
GitHub: https://github.com/rabeloo
*/
/*Saidas que poderão ser usadas pelos resources*/
output "sg_name" {
  value = "${aws_security_group.secGroup.name}"
}
output "sg_description" {
  value = "${aws_security_group.secGroup.description}"
}
output "sg_id" {
  value = "${aws_security_group.secGroup.id}"
}
output "sg_vpc_id" {
  value = "${aws_security_group.secGroup.vpc_id}"
}
output "sg_owner_id" {
  value = "${aws_security_group.secGroup.owner_id}"
}
output "sg_ingress" {
  value = "${aws_security_group.secGroup.ingress}"
}
output "sg_egress" {
  value = "${aws_security_group.secGroup.egress}"
}
