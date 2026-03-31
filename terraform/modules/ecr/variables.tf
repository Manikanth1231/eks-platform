variable "repositories"          { type = list(string) }
variable "environment"           { type = string }
variable "image_retention_count" { type = number  default = 10 }
variable "tags"                  { type = map(string) default = {} }
