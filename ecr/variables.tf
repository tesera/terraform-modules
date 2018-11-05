
variable "default_tags" {
  type = "map"
  default = {}
}

variable "ecr" {
  type = "list"
}

variable "build_compute_type" {
  default     = "BUILD_GENERAL1_SMALL"
}
variable "build_image" {
  default     = "aws/codebuild/docker:1.12.1"
}

