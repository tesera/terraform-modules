

data "null_data_source" "amis" {
  count = length(var.images)
  inputs = {
    amis = format("${data.aws_ami.main[count.index].image_id}~%s", join(",${data.aws_ami.main[count.index].image_id}~", values(var.sub_accounts)))
  }
}


locals {
  amis = split(",", join(",", data.null_data_source.amis.*.outputs.amis))
}
