output "ssh_key_v" {
  value = tls_private_key.ssh_key.public_key_openssh
}

output "ssh_key_filename_v" {
  value = "server_data/${var.key_srv_name}-ssh_key_${var.key_user_name}.pem"
}
