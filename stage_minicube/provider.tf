variable "my_provider" {
  # Variable settings see in credentials.auto.tfvars
  description = "provider settings"
  type        = map(string)
}
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.84.0"
    }
  }
}
provider "yandex" {
  service_account_key_file = file("ya_key.json")
  cloud_id                 = var.my_provider["cloud"]
  folder_id                = var.my_provider["folder"]
  zone                     = var.my_provider["zone"]
}

