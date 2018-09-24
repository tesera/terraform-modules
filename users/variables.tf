variable "name" {
  type = "string"
}

// {group:policy_id}
variable "groups" {
  type = "map"
  default = {}
}

// {username:[group,group]}
variable "users" {
  type = "map"
  default = {}
}
