resource "google_compute_global_forwarding_rule" "https" {
  name                  = "https"
  provider              = google-beta
  depends_on            = [google_compute_subnetwork.vpc_subnet]
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "443"
  target                = google_compute_target_https_proxy.terraform_target_proxy_https.id
  ip_version            = "IPV4"
}

resource "google_compute_ssl_policy" "terraform_ssl_policy" {
  name = "terraform-ssl-policy"
  profile = "COMPATIBLE"
}

resource "google_compute_ssl_certificate" "terraform_cert" {
  private_key = file("./keys/example.key")
  certificate = file("./keys/example.crt")

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      private_key
    ]
  }
}


resource "google_compute_target_https_proxy" "terraform_target_proxy_https" {
  name             = "terraform-load-balancer-target-proxy-2"
  url_map          = google_compute_url_map.terraform_url_map.id
  ssl_certificates = [google_compute_ssl_certificate.terraform_cert.id]
}

resource "google_compute_url_map" "terraform_url_map" {
  name            = "terraform-load-balancer"
  default_service = google_compute_backend_service.terraform_backend.id
}

resource "google_compute_backend_service" "terraform_backend" {
  name                  = "terraform-backend"
  provider              = google-beta
  protocol              = "HTTP"
  timeout_sec           = 30
  health_checks         = [google_compute_health_check.terraform_health_check.id]
  backend {
    group           = google_compute_region_instance_group_manager.terraform_ig_manager.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}



