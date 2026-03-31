variable "name"               { type = string }
variable "environment"        { type = string }
variable "vpc_id"             { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "cluster_version"    { type = string }
variable "instance_types"     { type = list(string) }
variable "desired_size"       { type = number }
variable "min_size"           { type = number }
variable "max_size"           { type = number }

variable "disk_size" {
  type    = number
  default = 50
}

variable "tags" {
  type    = map(string)
  default = {}
}
