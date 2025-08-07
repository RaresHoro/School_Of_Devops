variable "name_suffix" { type = string}
variable "key_name"{ type = string }
variable "subnet_id"{ type = string }
variable "sg_id"{ type = string }
variable "target_group_arn"{ type = string }
variable "nginx_text"{ type = string }
variable "nginx_path"{ type = string }
variable "tags"{ type = map(string) }