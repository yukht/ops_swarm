resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096

# Save a private key
  provisioner "local-exec" {
    command = sensitive("echo '${tls_private_key.ssh_key.private_key_pem}' > server_data/${var.key_srv_name}-ssh_key_${var.key_user_name}.pem && chmod 600 server_data/${var.key_srv_name}-ssh_key_${var.key_user_name}.pem")
  }

# Save a public key (optional, default false)
  provisioner "local-exec" {
    command = sensitive("if [[ ${var.key_pub_key_save} == true ]]; then echo '${tls_private_key.ssh_key.public_key_pem}' > server_data/${var.key_srv_name}-ssh_key_${var.key_user_name}.pub && chmod 600 server_data/${var.key_srv_name}-ssh_key_${var.key_user_name}.pub; fi;")
    interpreter = ["bash", "-c"]
  }

}
