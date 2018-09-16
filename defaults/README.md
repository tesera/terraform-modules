# defaults
Collection of module defaults

- account_id
- aws_region
- name:
- tags: 

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

## TODO ... tags: should be a list
```hcl-terraform
resource "****" "main" {
  ...
  tags = ["${module.defaults.tags_list}"]
}

```
