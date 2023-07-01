# variables may be share for main module
output "srv_subnet_id" {              # variable used by lb module call from main
  value = yandex_compute_instance.srv.network_interface[0].subnet_id
}
output "public_address" {
  value = yandex_compute_instance.srv.network_interface[0].nat_ip_address
}
output "private_address" {
  value = yandex_compute_instance.srv.network_interface[0].ip_address
}
