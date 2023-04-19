# These variables are used just to write in the name of key files
# If you have many keys, then this will help to find the right ones faster

variable "key_srv_name" {
  type      = string
}

variable "key_user_name" {
  type      = string
}

variable "key_pub_key_save" {
  type      = bool
  default   = "false"
}
