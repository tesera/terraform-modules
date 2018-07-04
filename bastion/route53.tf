# TODO future
//resource "aws_route53_record" "bastion" {
//  count = 0
//  zone_id = "${var.bastion_zone_id}"
//  name = "${var.bastion_domain_name}"
//  type = "A"
//  ttl = "${var.bastion_zone_ttl}"
//
//  records = ["${aws_eip.bastion_eip.public_ip}"]
//}


