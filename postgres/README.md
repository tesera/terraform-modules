# RDS
Creates a postgres RDS instance.

## Features
- RDS postgres instance
- db security group 
- db subnet group

## Setup

### Module

```hcl-terraform
module "db" {
  source                 = "github.com/tesera/terraform-modules/postgres"
  name                   = "rds-instance-name"
  db_name                = "db-name"
  username               = "db-user"
  password               = "SomePassword123"
  private_subnet_ids     = ["${module.vpc.private_subnet_ids}"]
}
```

### Add a security group rule that grants permission to security group sg-00000000 to access the db instance
```hcl-terraform
resource "aws_security_group_rule" "db_access" {
  source_security_group_id = "sg-00000000"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = "${module.db.security_group_id}"
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
- **db_name:** name of the database to create when the DB instance is created
- **username:** username for the master DB user
- **password:** password for the master DB user
- **private_subnet_ids:** list of VPC subnet IDs
- **storage_type:** "gp2" (general purpose SSD) is the best default choise - https://www.terraform.io/docs/providers/aws/r/db_instance.html#storage_type
- **engine:** database engine
- **engine_version:** database engine version. The currently supported version can be checked here - https://aws.amazon.com/rds/postgresql/faqs/
- **instance_class:** instance type of the RDS instance.
- **backup_window:** window of time when a backup can be triggered
- **parameter_group_name:** name of the DB parameter group to associate - https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithParamGroups.html. If we haven't created a custom group we should use the default group matching the engine version
- **allocated_storage:** amount of allocated storage in GB
- **backup_retention_period:** backup retention period
- **multi_az:** if the RDS instance is multi AZ enabled

## Output

- **postgres_endpoint:** connection endpoint
- **password:** password of the master DB user
- **username:** username of the master DB user
- **security_group_id:** the security group that was created and associated with this instance


## TODO
- [ ] Add ability to add read replicas by using https://www.terraform.io/docs/providers/aws/r/db_instance.html#replicate_source_db
- [ ] Add ability to create custom db parameter group - https://www.terraform.io/docs/providers/aws/r/db_parameter_group.html
- [ ] Add ability to add the PostGis extension - https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.html#Appendix.PostgreSQL.CommonDBATasks.PostGIS
