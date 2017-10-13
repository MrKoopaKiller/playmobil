/*
Author: Raphael Rabelo de Oliveira
GitHub: https://github.com/rabeloo
*/

/*Cria uma policy document necessária pela iam role*/
data "aws_iam_policy_document" "dataInstancePolicy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
/*Cria uma iam role com a saida json da policy*/
resource "aws_iam_role" "iamRole" {
  name = "iam-${var.tag_name}"
  assume_role_policy = "${data.aws_iam_policy_document.dataInstancePolicy.json}"
}
/*Cria um instance profile usado pela instancia*/
resource "aws_iam_instance_profile" "instProfile" {
  role = "${aws_iam_role.iamRole.name}"
}
/*Atacha a policy ao iam role*/
resource "aws_iam_policy_attachment" "policyAttach" {
  name       = "attach-${var.tag_name}"
  roles      = ["${aws_iam_role.iamRole.name}"]
  policy_arn = "${aws_iam_policy.iamPolicy.arn}"
}
