resource "aws_wafregional_ipset" "empty" {
  name = "${var.name}-empty-ipset"
}

locals {
  name           = "${replace("${var.name}", "/[^a-zA-Z0-9]/", "")}"                         # Sanitize name, waf labels follow different rules
  ipset_admin_id = "${var.ipAdminListId != "" ? var.ipAdminListId : aws_wafregional_ipset.empty.id}"
  ipset_white_id = "${var.ipWhiteListId != "" ? var.ipAdminListId : aws_wafregional_ipset.empty.id}"
  ipset_black_id = "${var.ipBlackListId != "" ? var.ipAdminListId : aws_wafregional_ipset.empty.id}"
}
