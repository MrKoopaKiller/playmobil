/*
Author: Raphael Rabelo de Oliveira
GitHub: https://github.com/rabeloo
*/
/*Template de user data usado para passar variaveis para o user data template. Nesse caso em especifico não foi necessário.*/
data "template_file" "user_data" {
  template = "${file("ec2_user_data_template.sh")}"
  vars = { }
}
