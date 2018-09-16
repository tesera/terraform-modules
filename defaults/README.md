# defaults
Collection of module defaults

- account_id
- aws_region
- name:
- tags: 
- tags_as_list_of_maps: tags in a list

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
  aws_region   = "${module.defaults.aws_region}"
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

### Error: ... tags: should be a list
```hcl-terraform
resource "aws_security_group" "main" {
  ...
  tags = ["${module.defaults.tags_as_list_of_maps}"]
}

```

Refs:
- https://github.com/jonbrouse/terraform-style-guide/blob/master/README.md#naming-conventions
- https://github.com/cloudposse/terraform-null-label


