# ElasticSearch
Creates a ElasticSearch domain.

## Features
- ElasticSearch domain - 
- Security group - assigned to the ElasticSearch domain

### Prerequisites
This module requires AWSServiceRoleForAmazonElasticsearchService service-linked role to exist. If it doesn't exist you are going to get an error like:
* aws_elasticsearch_domain.main: Error reading IAM Role AWSServiceRoleForAmazonElasticsearchService: NoSuchEntity: The role with name AWSServiceRoleForAmazonElasticsearchService cannot be found.

To fix this you need to apply the following terraform:
```hcl-terraform
resource "aws_iam_service_linked_role" "main" {
  aws_service_name = "es.amazonaws.com"
}
```

### Module
Connect directly to execute the indices creation script (without bastion host)
```hcl-terraform
module "elasticsearch" {
  source              = "git@github.com:tesera/terraform-modules//elasticsearch"
  name                = "elastic-search-name"
  private_subnet_ids  = ["subnet-00000000000000000", "subnet-00000000000000001"]
  vpc_id              = "vpc-00000000"
  indices_config_file = "mappings.json"
  security_group_ids  = ["sg-00000000000000000"]
}
```

Connect through bastion host to execute the indices creation script
```hcl-terraform
module "elasticsearch" {
  source              = "git@github.com:tesera/terraform-modules//elasticsearch"
  name                = "elastic-search-name"
  private_subnet_ids  = ["subnet-00000000000000000", "subnet-00000000000000001"]
  vpc_id              = "vpc-00000000"
  indices_config_file = "mappings.json"
  security_group_ids  = ["${module.bastion.security_group_id}","sg-00000000000000000"]
  ssh_identity_file   = "key.pem"
  bastion_ip          = "${module.bastion.public_ip}"
}
```

Sample index/mapping json - mapping.json:
```json
[
  {
    "index": "index1",
    "body": {
      "mappings": {
        "_doc": {
          "properties": {
            "field1": {
              "type": "text"
            }
          }
        }
      }
    }
  }
]
```

## Input
- **name:** name of the ElasticSearch domain.
- **default_tags:** default tags.
- **engine_version:** the version of Elasticsearch to deploy. [Default: 6.3].
- **vpc_id:** VPC id.
- **private_subnet_ids:** list of VPC subnet IDs. if multi_az = false exactly one subnet needs to be specified.
- **instance_type:** instance type of data nodes in the cluster. [Default: r4.large.elasticsearch]. 
- **node_count:** number of instances in the cluster. [Default: 2].
- **dedicated_master_enabled:** indicates whether dedicated master nodes are enabled for the cluster. [Default: false].
- **dedicated_master_type:** instance type of the dedicated master nodes in the cluster.
- **dedicated_master_count:** number of dedicated master nodes in the cluster. [Default: 0].
- **multi_az:** specifies whether zone awareness is enabled. [Default: true].
- **automated_snapshot_start_hour:** hour during which the service takes an automated daily snapshot of the indices in the domain. [Default: 23].
- **ebs_volume_type:** the type of EBS volumes attached to data nodes. Valid values: gp2, io1, standard. [Default: io1].
- **ebs_volume_size:** the size of EBS volumes attached to data nodes (in GB). [Default: 35].
- **ebs_iops:** the baseline input/output (I/O) performance of EBS volumes attached to data nodes. Applicable only for the Provisioned IOPS EBS volume type. [Default: 1000].
- **log_publishing_options:** log publishing options - https://www.terraform.io/docs/providers/aws/r/elasticsearch_domain.html#log_type.
- **cognito_options:** options for Amazon Cognito authentication with Kibana - https://www.terraform.io/docs/providers/aws/r/elasticsearch_domain.html#enabled-3
- **security_group_ids:** list of security group ids which are going to be granted access to the ElasticSearch domain.
- **ssh_identity_file:** SSH key filename for connecting to the bastion host
- **ssh_username:** username for connecting to the bastion host
- **bastion_ip:** IP of the bastion host. If it is not provided the creation of the indices will run directly against the Elasticsearch endpoint without SSH tunneling.

## Output

- **arn:** ARN of the domain.
- **domain_id:** unique identifier for the domain.
- **domain_name:** the name of the Elasticsearch domain.
- **endpoint:** domain-specific endpoint used to submit index, search, and data upload requests.
- **kibana_endpoint:** domain-specific endpoint for kibana without https scheme.
- **availability_zones:** the names of the availability zones.
- **vpc_id:** the ID of the VPC.
- **security_group_id:** the security group that was created and associated with this ElasticSearch domain.

## Index migration/update
The new index needs to be created first, and then the alias to be redirected to the new index, by calling client.indices.updateAlias with two actions:
 - "remove" - removing the existing alias and;
 - "add" - creating an alias with the same name pointing to the new index.
