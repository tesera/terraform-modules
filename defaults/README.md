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
- **tags_as_list_of_maps:** Tags mapped to a list (ie for `aws_security_group`)

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

### Error: ... tags: should be a list
```hcl-terraform
resource "aws_security_group" "main" {
  ...
  tags = ["${module.defaults.tags_as_list_of_maps}"]
}

```

## Refs
- https://github.com/jonbrouse/terraform-style-guide/blob/master/README.md#naming-conventions
- https://github.com/cloudposse/terraform-null-label

## TODO
- [ ] Add in Cost Center tags
