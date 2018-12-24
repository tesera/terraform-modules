# Packer
Packer scripts for creating up to date AMIs for faster initial boot time.
The subfolders are named as their respective terraform modules e.g. the scripts 
for creating AMI for the bastion modules are in "bastion" subfolder.
Creating the AMI in all required regions is a prerequisite for using the ec2, bastion and ecs terraform modules.

## Features
- Updated operating system 
- CloudWatch logging enabled
- CloudWatch agent for collecting additional metrics
- Inspector agent for allowing running of security assessments in Amazon Inspector
- SSM Agent for allowing shell access from Session AWS Systems Manager
- bastion AMI only - `authorized_keys` generated from users in an IAM group

## Requirements
```bash
$ brew install packer
```

## Setup
To create the AMIs, go to the respective subfolder, edit the `variables.json`, and run:
```bash
packer build -var-file=variables.json ami.json
```

## Input - these are located in variables.json
- **profile** the profile to use in the shared credentials file for AWS. 
- **ami_regions:** a list of regions to copy the AMI to. Tags and attributes are copied along with the AMI. 
- **region:** the name of the region, such as us-east-1, in which to launch the EC2 instance to create the AMI.
- **user_data.sh:** - this file contain the provisioning shell script.

## Output 
Along with the entire output from running the provisioning commands at the end of successfull execution the AMI ids in all regions are displayed.


