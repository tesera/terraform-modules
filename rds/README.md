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

### Using SSL to Encrypt a Connection to RDB
Force use of SSL needs to be set through DB Parameters groups. Example of creating such param group:
```hcl-terraform
resource "aws_db_parameter_group" "postgres10" {
  name   = "${var.name}-postgres10"
  family = "postgres10"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }
}
```
https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/UsingWithRDS.SSL.html


### IAM authentication
Knowledge centre video for setting this up with mysql - https://aws.amazon.com/premiumsupport/knowledge-center/users-connect-rds-iam/

After setting iam_database_authentication_enabled = true, the steps for connecting with IAM credentials are:

 - create IAM Policy for IAM Database Access - https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.IAMPolicy.html :
 ```json
 {
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Action": [
             "rds-db:connect"
         ],
         "Resource": [
             "arn:aws:rds-db:${region}:${account-id}:dbuser:${dbi-resource-id}/${db-user-name}"
         ]
      }
   ]
}
```

 - create Database Account Using IAM Authentication:
 ``` PL/pgSQL
  CREATE USER db_userx WITH LOGIN; 
  GRANT rds_iam TO db_userx;
```

 - connect to RDS from the Command Line: AWS CLI and psql Client - https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/UsingWithRDS.IAMDBAuth.Connecting.AWSCLI.PostgreSQL.html
Currently there is a known issue with generating (Postgres and Aurora/Postgres) RDS credentials ("aws rds generate-db-auth-token") with implicitly assumed EC2 role (e.g. role attached to EC2) - you will get an error "PAM Authentication failed":
 https://forums.aws.amazon.com/thread.jspa?threadID=291106
 https://github.com/aws/amazon-ecs-agent/issues/1604
The workaround is either assume the role as an IAM user, or attach the rdb-connect policy to the IAM user directly.

### Custom Parameter Group
```hcl-terraform
# https://www.terraform.io/docs/providers/aws/r/db_parameter_group.html

# https://www.terraform.io/docs/providers/aws/r/rds_cluster_parameter_group.html

```

### Output configuration info to SSM Param store for use from Serverless, Lambda or other components
Force use of SSL needs to be set through DB Parameters groups. Example of creating such param group:
```hcl-terraform
resource "aws_ssm_parameter" "db_endpoint" {
  name        = "/config/database/endpoint"
  description = "Endpoint to connect to the database"
  type        = "SecureString"
  value       = "${module.db.endpoint}"
}

resource "aws_ssm_parameter" "db_port" {
  name        = "/config/database/port"
  description = "Port to connect to the database"
  type        = "SecureString"
  value       = "${module.db.port}"
}

resource "aws_ssm_parameter" "db_username" {
  name        = "/config/database/username"
  description = "Username to connect to the database"
  type        = "SecureString"
  value       = "${module.db.username}"
}
```

## Input
- **type:** type of RDS. [Default: `service`]. Valid values: `service`, `cluster`.
- **name:** name of the RDS instance
- **vpc_id:** VPC id 
- **db_name:** name of the database to create when the DB instance is created [Defaults to `var.name`]
- **username:** username for the master DB user [Default: `admin`]
- **password:** password for the master DB user
- **private_subnet_ids:** list of VPC subnet IDs
- **storage_type:** "gp2" (general purpose SSD) is the best default choice - https://www.terraform.io/docs/providers/aws/r/db_instance.html#storage_type
- **engine:** database engine [Default: `postgres`], for `type=cluster` use `aurora-postgresql`
- **engine_version:** database engine version. [Default: `10`] The currently supported version can be checked here - https://aws.amazon.com/rds/postgresql/faqs/
- **engine_mode:** The database engine mode. Used only with type = cluster. Valid values: `provisioned`, `serverless`. [Default: `provisioned`]. Limitations when using serverless - https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/aurora-serverless.html
- **instance_type:** instance type of the RDS instance. encryption will be turned on for all `db.*.*large` instances [Default: `db.t2.micro`]
- **backup_window:** window of time when a backup can be triggered
- **parameter_group_name:** name of the DB parameter group to associate - https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithParamGroups.html. If we haven't created a custom group we should use the default group matching the engine version. [Default: `default.${engine}${engine_version}`]
- **allocated_storage:** amount of allocated storage in GB
- **backup_retention_period:** backup retention period
- **multi_az:** if the RDS instance is multi AZ enabled [Default: `true`]
- **replica_count:** number of read replicas to deploy
- **security_group_ids:** list of security group ids which are going to be granted access to the DB. [Default: []]
- **ssh_identity_file:** SSH key filename for connecting to the bastion host
- **bastion_ip:** IP of the bastion host. If it is not provided the psql command will run directly against the RDS host without SSH tunneling 
- **init_scripts_folder:** sub folder containing the sql init scripts to be executed. The script files must have .sql extenstion. And all of the scripts must end with ";".
All scripts are going to be executed in a single transaction against the database specified in db_name. 
- **ssh_username:** username for connecting to the bastion host
- **apply_immediately:** specifies whether any database modifications are applied immediately, or during the next maintenance window. [Default: `false`]. 
- **iam_database_authentication_enabled:** specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled. [Default: `false`].
- **skip_final_snapshot:**  determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final_snapshot_identifier. [Default: false].
- **node_count:** count of aurora instances to be created in the aurora cluster. Used only with type = cluster. [Default: `1`].

## Output

- **endpoint:** connection endpoint
- **replica_endpoints:** read replica endpoints
- **password:** password of the master DB user
- **username:** username of the master DB user
- **security_group_id:** the security group that was created and associated with this instance
- **billing_suggestion:** comments to improve billing cost


## TODO
- [ ] Add ability to create custom db parameter group - https://www.terraform.io/docs/providers/aws/r/db_parameter_group.html
- [ ] Add ability to add the PostGis extension - https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.html#Appendix.PostgreSQL.CommonDBATasks.PostGIS
