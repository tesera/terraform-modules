variable "name" {
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "engine" {
  description = "this is a dummy placeholder. is not used"
  default     = "elasticsearch"
}

variable "engine_version" {
  default = "6.3"
}

variable "vpc_id" {
  type = string
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "type" {
  description = "this is dummy placeholder"
  default     = "service"
}

#r4.large is required since not all instance types support encrypt_at_rest
variable "instance_type" {
  default = "r4.large.elasticsearch"
}

variable "node_count" {
  default = 2
}

variable "dedicated_master_enabled" {
  default = "false"
}

variable "dedicated_master_type" {
  default = ""
}

variable "dedicated_master_count" {
  default = 0
}

variable "multi_az" {
  default = true
}

variable "automated_snapshot_start_hour" {
  default = 23
}

variable "ebs_volume_type" {
  default = "io1"
}

variable "ebs_volume_size" {
  default = 35
}

variable "ebs_iops" {
  default = 1000
}

variable "log_publishing_options" {
  type    = list(string)
  default = []
}

variable "cognito_options" {
  type    = list(string)
  default = []
}

variable "bootstrap_file" {
  default = ""
}

variable "ssh_identity_file" {
  default = ""
}

variable "ssh_username" {
  default = "ec2-user"
}

variable "bastion_ip" {
  default = ""
}

