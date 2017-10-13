/*
Author: Raphael Rabelo de Oliveira
GitHub: https://github.com/rabeloo
*/

/*Cria uma policy a ser usada na IAM role da instancia*/
data "aws_iam_policy_document" "dataPolicy" {
  statement {
    actions = [
      "ec2:DescribeTags",
      "ec2:CreateTags",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "iamPolicy" {
  name = "${var.tag_name}-policy"
  path = "/"
  description = "IAM Policy for ${var.tag_name}"
  policy = "${data.aws_iam_policy_document.dataPolicy.json}"
}
