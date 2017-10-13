/*
Author: Raphael Rabelo de Oliveira
GitHub: https://github.com/rabeloo
*/
/*Cria um internet gateway*/
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
  tags {
    Name = "main"
  }
}
