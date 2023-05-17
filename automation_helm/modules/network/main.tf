# Модуль для создания серверных подсетей
resource "yandex_vpc_subnet" "servers-subnet" {
  network_id      = var.network_id
  folder_id       = var.folder_id
  description     = var.network_description
  name            = var.network_name
  zone            = var.network_zone 
  v4_cidr_blocks  = var.network_v4_cidr_blocks
}
