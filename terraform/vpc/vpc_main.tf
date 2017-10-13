/*
Author: Raphael Rabelo de Oliveira
GitHub: https://github.com/rabeloo
*/
/*Cria VPC com o CIDR definido no arquivo vars.tf*/
resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr}"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags {
    Name = "main"
  }
}
