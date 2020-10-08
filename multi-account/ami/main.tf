data "aws_ami" "main" {
  count       = length(var.images)
  most_recent = true

  filter {
    name = "name"

    values = [
      var.images[count.index],
    ]
  }

  filter {
    name = "virtualization-type"

    values = [
      "hvm",
    ]
  }

  owners = [
    "self",
  ]
}

resource "aws_ami_launch_permission" "main" {
  count      = length(local.amis)
  image_id   = split("~", local.amis[count.index])[0]
  account_id = split("~", local.amis[count.index])[1]
}
