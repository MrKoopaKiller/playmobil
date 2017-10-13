/*
Author: Raphael Rabelo de Oliveira
GitHub: https://github.com/rabeloo
*/

/*Procura na conta uma AMI com o nome iniciado pelo nome definido, sempre utiliza a ultima versão criada*/
data "aws_ami" "myapp_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["myapp_*"]
  }
}

