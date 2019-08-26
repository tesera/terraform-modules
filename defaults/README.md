# defaults
Collection of module defaults

## Input
- **name:** name of application
- **tags:** module default tags

## Output
- **account_id:** Current Account ID
- **region:** Current AWS Region
- **name:** Sanitized `name`
- **name_alphanumeric:** Sanitized `name` that is only `[a-zA-Z0-9]` (ie for AWS WAF)
- **tags:** tags merged with defaults

## Use
```hcl-terraform
variable "default_tags" {
  type = "map"
  default = {}
}

module "defaults" {
  source = "../defaults"
  name = "${var.name}"
  tags = "${var.default_tags}"
}

locals {
  account_id   = "${module.defaults.account_id}"
  region   = "${module.defaults.region}"
  name         = "${module.defaults.name}"
  tags         = "${module.defaults.tags}"
}

resource "****" "main" {
  ...
  tags = "${merge(local.tags, map(
    "Name", "${local.name}-****",
    "Description", "Does x"
  ))}"
}

```

```hcl-terraform
resource "aws_autoscaling_group" "asg_ec2" {
  ...
  dynamic "tag" {
    for_each = local.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
```

## Refs
- https://github.com/jonbrouse/terraform-style-guide/blob/master/README.md#naming-conventions
- https://github.com/cloudposse/terraform-null-label
- https://stackoverflow.com/questions/53698758/how-do-i-apply-a-map-of-tags-to-aws-autoscaling-group

## TODO
- [ ] Add in Cost Center tags
