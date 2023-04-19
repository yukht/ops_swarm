variable "srv_family" {
  type    = string
}

variable "srv_default_user" {
  type    = string
}

variable "srv_second_user" {
  type    = string
}

variable "srv_key1" {
  type    = string
}

variable "srv_key2" {
  type    = string
}

variable "srv_name" {
  type    = string
}

variable "srv_description" {
  type    = string
}

variable "srv_zone" {
  type    = string
}

variable srv_platform_id {
  type    = string
}

variable srv_core_fraction {
  type    = string  
}

variable "srv_cores" {
  type    = number
}

variable "srv_memory" {
  type    = number
}

variable srv_disk_size {
  type    = number  
}

variable "srv_subnet" {
  type    = string
}

variable "srv_ip" {
  type    = string
}

variable "srv_nat" {
  type    = bool
}
