# EFS
Creates and Elastic File System (EFS) and Elastic File System (EFS) mount target.

## Setup
### Module
```hcl-terraform

module "efs" {
  source    = "git@github.com:tesera/terraform-modules/efs"
  name      = ""${local.name}"
  subnet_id = "subnet-00000000"
}

```

## Input
- **name:** name of the efs.
- **default_tags:** tags merged with defaults.
- **subnet_id:** the ID of the subnet to add the mount target in.
- **kms_key_id:** the ARN for the KMS encryption key. 
- **performance_mode:** the file system performance mode. Can be either "generalPurpose" or "maxIO" [Default: "generalPurpose"].
- **provisioned_throughput_in_mibps:** the throughput, measured in MiB/s, that you want to provision for the file system. Valid range is 1-1024 MiB/s. Only applicable with throughput_mode set to provisioned.
- **throughput_mode:** throughput mode for the file system. [Default: bursting]. Valid values: bursting, provisioned. When using provisioned, also set provisioned_throughput_in_mibps.
- **ip_address:** the address (within the address range of the specified subnet) at which the file system may be mounted via the mount target.
- **security_groups:** a list of up to 5 VPC security group IDs (that must be for the same VPC as subnet specified) in effect for the mount target.

## Output
- **efs_id:** the ID that identifies the file system.
- **efs_dns_name:** the DNS name for the filesystem - http://docs.aws.amazon.com/efs/latest/ug/mounting-fs-mount-cmd-dns-name.html.
- **mount_target_id:** the ID of the mount target.
- **mount_target_dns_name:** the DNS name for the given subnet/AZ - http://docs.aws.amazon.com/efs/latest/ug/mounting-fs-mount-cmd-dns-name.html.
- **mount_target_network_interface_id:** the ID of the network interface that Amazon EFS created when it created the mount target.
- **security_group_id:** the security group that was created and associated with mount target. To be referenced for creating security group rules that grant access to the mount target on port 2049. 
