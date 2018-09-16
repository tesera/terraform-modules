output "account_id" {
  value = "${local.account_id}"
}

output "aws_region" {
  value = "${local.aws_region}"
}

output "name" {
  value = "${local.name}"
}

output "tags" {
  value = "${local.tags}"
}

output "tags_as_list_of_maps" {
  value = ["${data.null_data_source.tags_as_list_of_maps.*.outputs}"]
}
