variable "images" {
  type = list(string)
  default = [
    "amzn2-ami-hvm-*-x86_64-gp2-ssh-bastion",
    "amzn2-ami-hvm-*-x86_64-gp2",
    "amzn2-ami-ecs-hvm-*-x86_64-ebs",
    "amzn-ami-vpc-nat-hvm-*-x86_64-ebs"
  ]
}

variable "sub_accounts" {
  type    = map(string)
  default = {}
}
