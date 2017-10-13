/*
Author: Raphael Rabelo de Oliveira
GitHub: https://github.com/rabeloo
*/
/*Utiliza o provider AWS na região especificada no arquivo vars.tf*/
provider "aws" {
  region = "${var.region}"
}

/*Datasource usado para capturar informações da VPC provisionada, com isso é possível acessar variáveis de outro projeto para serem usadas.*/
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    region = "${var.region}"
    bucket = "${var.bucket_name}"
    key = "vpc/vpc.tfstate"
  }
}
