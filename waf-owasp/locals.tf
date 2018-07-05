resource "aws_waf_ipset" "empty" {
  name = "${var.name}-empty-ipset"
}

locals {
  ipset_admin_id = "${var.ipAdminListId != "" ? var.ipAdminListId : aws_waf_ipset.empty.id}"
  ipset_white_id = "${var.ipWhiteListId != "" ? var.ipAdminListId : aws_waf_ipset.empty.id}"
  ipset_black_id = "${var.ipBlackListId != "" ? var.ipAdminListId : aws_waf_ipset.empty.id}"
}
