# Creating a virtual machine
data "yandex_compute_image" "srv_image_data" {
  family = var.srv_family
}
resource "yandex_compute_instance" "srv" {
  name        = var.srv_name
  description = var.srv_description
  zone        = var.srv_zone
  hostname    = var.srv_name
  # use standard-v3 for apply 50% core_fraction and standard-v1 (Intel Broadwell) for minumim server price (with 20% core_fraction)
  platform_id = var.srv_platform_id

  resources {
    cores  = var.srv_cores
    core_fraction = var.srv_core_fraction
    memory = var.srv_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.srv_image_data.image_id
      size     = var.srv_disk_size
    }
  }

  network_interface {
    subnet_id = var.srv_subnet                  # This example implies a network created by the network module
    ip_address = var.srv_ip
    nat = var.srv_nat                           # To create a balancer, an external address is needed (true)
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    #    ssh-keys = "ubuntu:${file("./ssh_key_ansible1_srv.pub")}"
    user-data = "#cloud-config\nusers:\n  - default\n  - name: ${var.srv_default_user}\n    groups: sudo\n    shell: /bin/bash\n    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n    ssh_authorized_keys:\n      - ${var.srv_key1}\n  - name: ${var.srv_second_user}\n    groups: sudo\n    shell: /bin/bash\n    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n    ssh_authorized_keys:\n      - ${var.srv_key2}\n"
  }
}

