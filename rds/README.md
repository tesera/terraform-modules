# RDS
Creates a RDS instance.

## Features
- RDS instance
- db security group 
- db subnet group
- executes initial sql script against the newly created DB

## Setup

### Module

```hcl-terraform
module "rds" {
  source                   = "git@github.com:tesera/terraform-modules//postgres"
  vpc_id                   = "${module.vpc.id}"
  name                     = "rds-instance-name"
  db_name                  = "dbname"
  username                 = "dbuser"
  password                 = "SomePassword123"
  private_subnet_ids       = ["${module.vpc.private_subnet_ids}"]
  ssh_identity_file        = "key"
  bastion_ip               = "${module.bastion.public_ip}"
  init_scripts_folder      = "scripts"
  ssh_username             = "ec2-user"
  security_group_ids       = ["${module.bastion.security_group_id}"]
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
- **type:** type of RDS. [Default: `service`]. Valid values: service, cluster.
- **name:** name of the RDS instance
- **vpc_id:** VPC id 
- **db_name:** name of the database to create when the DB instance is created [Defaults to `var.name`]
- **username:** username for the master DB user [Default: `admin`]
- **password:** password for the master DB user
- **private_subnet_ids:** list of VPC subnet IDs
- **storage_type:** "gp2" (general purpose SSD) is the best default choice - https://www.terraform.io/docs/providers/aws/r/db_instance.html#storage_type
- **engine:** database engine [Default: postgres]
- **engine_version:** database engine version. [Default: 10.x] The currently supported version can be checked here - https://aws.amazon.com/rds/postgresql/faqs/
- **engine_mode:** The database engine mode. Used only with type = cluster. Valid values: provisioned, serverless. [Default: provisioned]. Limitations when using serverless - https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/aurora-serverless.html
- **instance_class:** instance type of the RDS instance. encryption will be turned on for all `db.*.*large` instances
- **backup_window:** window of time when a backup can be triggered
- **parameter_group_name:** name of the DB parameter group to associate - https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithParamGroups.html. If we haven't created a custom group we should use the default group matching the engine version
- **allocated_storage:** amount of allocated storage in GB
- **backup_retention_period:** backup retention period
- **multi_az:** if the RDS instance is multi AZ enabled
- **replica_count:** number of read replicas to deploy
- **security_group_ids:** list of security group ids which are going to be granted access to the DB. [Default: []]
- **ssh_identity_file:** SSH key filename for connecting to the bastion host
- **bastion_ip:** IP of the bastion host. If it is not provided the psql command will run directly against the RDS host without SSH tunneling 
- **init_scripts_folder:** sub folder containingthe sql init scripts to be executed. The script files must have .sql extenstion. And all of the scripts must end with ";".
All scripts are going to be executed in a single transaction against the database specified in db_name. 
- **ssh_username:** username for connecting to the bastion host
- **apply_immediately:** specifies whether any database modifications are applied immediately, or during the next maintenance window. [Default: false]. 
- **skip_final_snapshot:**  determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final_snapshot_identifier. [Default: false].
- **instance_count:** count of aurora instances to be created in the aurora cluster. Used only with type = cluster. [Default: 1].
- **cluster_engine:** database engine for the aurora cluster. Used only with type = cluster. [Default: aurora-postgresql]

## Output

- **endpoint:** connection endpoint
- **password:** password of the master DB user
- **username:** username of the master DB user
- **security_group_id:** the security group that was created and associated with this instance
- **billing_suggestion:** comments to improve billing cost


## TODO
- [ ] Add ability to create custom db parameter group - https://www.terraform.io/docs/providers/aws/r/db_parameter_group.html
- [ ] Add ability to add the PostGis extension - https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.html#Appendix.PostgreSQL.CommonDBATasks.PostGIS
