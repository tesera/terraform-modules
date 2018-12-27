# EFS
Creates and Elastic File System (EFS) and Elastic File System (EFS) mount target.

## Setup
### Module
```hcl-terraform
 module "efs" {
  source    = "git@github.com:tesera/terraform-modules//efs"
  name      = "${local.name}"
  subnet_ids = ["subnet-00000000"]
}
```
 
## Input
- **name:** name of the efs.
- **default_tags:** tags merged with defaults.
- **subnet_ids:** the IDs of the subnets, for which to create mount targets. ONLY one mount target in each Availability Zone is allowed. All EC2 instances in a VPC within a given Availability Zone share a single mount target for a given file system.
- **kms_key_id:** the ARN for the KMS encryption key. 
- **performance_mode:** the file system performance mode. Can be either "generalPurpose" (General Purpose Performance Mode) or "maxIO" (Max I/O Performance Mode) [Default: "generalPurpose"]. https://docs.aws.amazon.com/efs/latest/ug/performance.html
- **provisioned_throughput_in_mibps:** the throughput, measured in MiB/s, that you want to provision for the file system. Valid range is 1-1024 MiB/s. Only applicable with throughput_mode set to provisioned.
- **throughput_mode:** throughput mode for the file system. [Default: bursting]. Valid values: bursting, provisioned. When using provisioned, also set provisioned_throughput_in_mibps.

## Output
- **efs_id:** the ID that identifies the file system.
- **efs_dns_name:** the DNS name for the filesystem - http://docs.aws.amazon.com/efs/latest/ug/mounting-fs-mount-cmd-dns-name.html.
- **mount_target_ids:** the ID of the mount target.
- **mount_target_dns_names:** the DNS name for the given subnet/AZ - http://docs.aws.amazon.com/efs/latest/ug/mounting-fs-mount-cmd-dns-name.html.
- **mount_target_network_interface_ids:** the ID of the network interface that Amazon EFS created when it created the mount target.
- **security_group_id:** the security group that was created and associated with this EFS

