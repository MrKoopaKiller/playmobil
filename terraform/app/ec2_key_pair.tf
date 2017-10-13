/*
Author: Raphael Rabelo de Oliveira
GitHub: https://github.com/rabeloo
*/

/*Importa uma key pre-criada para ser usada no acesso a instancia via ssh.*/
resource "aws_key_pair" "keyPair" {
  key_name   = "${var.tag_name}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNq1RhuiwZgIm8I6/0e/+FViNbOB12gOTG961/TT2G/msM1vsdypWT4JnB0trcrny274JzP7w8SJv5kKPcC3yOFnSeRinse3GIiBX84+ajdchn3BDsLZsHpm9Clpi2ISrssLQ0mTaIC5zkmGphKcA8XjeCht6j/hwcZJc64u0/qGFeIb2kgwYrQFbxY9Xm5TjSfzBcu+8XkRJQB6YKfQ51vqtd8w/CyX5nCGdz0rHWIdYbxCUlnIMQSdwTq5pwR3ZWdSGUyBBpDoKEFNTUzkxqe3HEK+qNui2SF1jbqKXFOSMpj6k36r84OI6iOkqx4v10NhburZKzXkCFE+wIxroF rabelo@ridley.local"
}

