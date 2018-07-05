# DynamoDB
Creates a DynamoDB table.

## Setup

### Module

```hcl-terraform
module "dynamodb" {
  source = "git@github.com:tesera/terraform-modules//dynamodb"
  table_name = "${var.env}-${var.name}"
  hash_key = "table-name-hash-key"
  range_key = "table-name-range-key"
}
```

## Input
- **name:** table name
- **hash_key:** attribute to use as the hash (partition) key
- **range_key:** attribute to use as the range (sort) key
- **min_read_capacity:** min number of read units for this table, also used as initial value for number of read units
- **max_read_capacity:** max number of read units for this table that can be reached by the autoscalling
- **min_write_capacity** min number of write units for this table, also used as initial value for number of write units
- **max_write_capacity:** max number of write units for this table that can be reached by the autoscalling
- **read_target_value:** read target utilization of the scaling policy
- **write_target_value:** write target utilization for the scaling policy

## Output
- **table_name:** table name
