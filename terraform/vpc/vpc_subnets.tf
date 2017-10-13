/*
Author: Raphael Rabelo de Oliveira
GitHub: https://github.com/rabeloo
*/

/*Cria as subnets públicas com base nas zonas de disponibilidade configuradas em vars.tf*/
resource "aws_subnet" "public-subnet" {
    count                   = "${length(split(",", lookup(var.azs, var.region)))}"
    vpc_id                  = "${aws_vpc.main.id}"
    cidr_block              = "${cidrsubnet(var.vpc_cidr, 8, count.index + 3)}"
    availability_zone       = "${element(split(",", lookup(var.azs, var.region)), count.index)}"
    map_public_ip_on_launch = true
    tags {
        "Name" = "public-${element(split(",", lookup(var.azs, var.region)), count.index)}"
    }
}
/*Cria uma route table que será usada por todas as subnets publicas*/
resource "aws_route_table" "rt_public" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags {
    Name = "public_subnets"
  }
}
/*Associa a route table as subnets publicas*/
resource "aws_route_table_association" "rt_public" {
  count          = "${length(split(",", lookup(var.azs, var.region)))}"
  subnet_id      = "${element(aws_subnet.public-subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.rt_public.id}"
}

/*
PRIVATE SUBNETS
*/
/*Cria as subnets privadas com base nas zonas de disponibilidade configuradas em vars.tf*/
resource "aws_subnet" "private-subnet" {
    count             = "${length(split(",", lookup(var.azs, var.region)))}"
    vpc_id            = "${aws_vpc.main.id}"
    cidr_block        = "${cidrsubnet(var.vpc_cidr, 8, count.index + 1)}"
    availability_zone = "${element(split(",", lookup(var.azs, var.region)), count.index)}"
    map_public_ip_on_launch = false
    tags {
        "Name" = "private-${element(split(",", lookup(var.azs, var.region)), count.index)}"
    }
}
/*Cria uma route table que será usada por todas as subnets privadas*/
resource "aws_route_table" "rt_private" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.natgw.id}"
  }
  tags {
    Name = "private_subnets"
  }
}
/*Associa a route table as subnets privadas*/
resource "aws_route_table_association" "rt_private" {
  count          = "${length(split(",", lookup(var.azs, var.region)))}"
  subnet_id      = "${element(aws_subnet.private-subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.rt_private.id}"
}
