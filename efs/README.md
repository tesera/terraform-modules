# EFS
Creates and Elastic File System (EFS).

## Setup
### Module
```hcl-terraform

module "efs" {
  source    = "git@github.com:tesera/terraform-modules/efs"
  name      = ""${local.name}"
}

```

## Input
- **name:** name of the efs.
- **default_tags:** tags merged with defaults.
- **kms_key_id:** the ARN for the KMS encryption key. 
- **performance_mode:** the file system performance mode. Can be either "generalPurpose" or "maxIO" [Default: "generalPurpose"].
- **provisioned_throughput_in_mibps:** the throughput, measured in MiB/s, that you want to provision for the file system. Valid range is 1-1024 MiB/s. Only applicable with throughput_mode set to provisioned.
- **throughput_mode:** throughput mode for the file system. [Default: bursting]. Valid values: bursting, provisioned. When using provisioned, also set provisioned_throughput_in_mibps.

## Output
- **efs_id:** the ID that identifies the file system.
- **efs_dns_name:** the DNS name for the filesystem - http://docs.aws.amazon.com/efs/latest/ug/mounting-fs-mount-cmd-dns-name.html.
