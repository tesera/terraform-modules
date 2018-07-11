# RDS
Creates a RDS instance.

## Features
- RDS instance
- db security group 
- db subnet group

## Setup

### Module

```hcl-terraform
module "rds" {
  source                 = "git@github.com:tesera/terraform-modules//postgres"
  vpc_id                 = "${module.vpc.id}"
  name                   = "rds-instance-name"
  db_name                = "dbname"
  username               = "dbuser"
  password               = "SomePassword123"
  private_subnet_ids     = ["${module.vpc.private_subnet_ids}"]
}
```

### Add a security group rule that grants permission to security group sg-00000000 to access the db instance
```hcl-terraform
resource "aws_security_group_rule" "rds" {
  security_group_id        = "${module.rds.security_group_id}"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = "${module.bastion.security_group_id}"
}
```

### IAM policy granting access to the new db resource
```json
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[],
         "Resource":[
            "${module.db.arn}"
         ]
      }
   ]
}
```

## Input

- **name:** name of the RDS instance
- **vpc_id:** VPC id 
- **db_name:** name of the database to create when the DB instance is created [Defaults to `var.name`]
- **username:** username for the master DB user [Default: `admin`]
- **password:** password for the master DB user
- **private_subnet_ids:** list of VPC subnet IDs
- **storage_type:** "gp2" (general purpose SSD) is the best default choice - https://www.terraform.io/docs/providers/aws/r/db_instance.html#storage_type
- **engine:** database engine
- **engine_version:** database engine version. The currently supported version can be checked here - https://aws.amazon.com/rds/postgresql/faqs/
- **instance_class:** instance type of the RDS instance. encryption will be turned on for all `db.*.*large` instances
- **backup_window:** window of time when a backup can be triggered
- **parameter_group_name:** name of the DB parameter group to associate - https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithParamGroups.html. If we haven't created a custom group we should use the default group matching the engine version
- **allocated_storage:** amount of allocated storage in GB
- **backup_retention_period:** backup retention period
- **multi_az:** if the RDS instance is multi AZ enabled
- **replica_count:** Number of read replicas to deploy

## Output

- **endpoint:** connection endpoint
- **password:** password of the master DB user
- **username:** username of the master DB user
- **security_group_id:** the security group that was created and associated with this instance
- **billing_suggestion:** comments to improve billing cost


## TODO
- [ ] Add ability to create custom db parameter group - https://www.terraform.io/docs/providers/aws/r/db_parameter_group.html
- [ ] Add ability to add the PostGis extension - https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.html#Appendix.PostgreSQL.CommonDBATasks.PostGIS
