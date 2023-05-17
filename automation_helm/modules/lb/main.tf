resource "yandex_lb_network_load_balancer" "lb-web" {
  name = var.lb_name
#  region_id = var.lb_region_id
  listener {
    name = "http-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
#    internal_address_spec {
#      subnet_id = var.lb_subnet_id     # only for internal lb
#    }
  }

  listener {
    name = "https-listener"
    port = 443
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = var.lb_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }

  }
}

