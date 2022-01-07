# resource "google_compute_global_forwarding_rule" "terraform-load-balancer-forwarding-rule" {
#   name                  = "terraform-load-balancer-forwarding-rule"
#   provider              = google-beta
#   depends_on            = [google_compute_subnetwork.vpc_subnet]
#   ip_protocol           = "TCP"
#   load_balancing_scheme = "EXTERNAL"
#   port_range            = "80"
#   target                = google_compute_target_http_proxy.terraform-target-proxy-http.id
#   ip_version = "IPV4"
# }

resource "google_compute_global_forwarding_rule" "https" {
  name                  = "https"
  provider              = google-beta
  depends_on            = [google_compute_subnetwork.vpc_subnet]
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "443"
  target                = google_compute_target_https_proxy.terraform-target-proxy-https.id
  ip_version = "IPV4"
}

resource "google_compute_ssl_certificate" "terraform-cert" {
  private_key = file("./keys/example.key")
  certificate = file("./keys/example.crt")

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      private_key
    ]
  }
}


resource "google_compute_target_https_proxy" "terraform-target-proxy-https" {
  name     = "terraform-load-balancer-target-proxy-2"
  provider = google-beta
  url_map  = google_compute_url_map.terraform-url-map.id
  ssl_certificates = [google_compute_ssl_certificate.terraform-cert.id]
}

resource "google_compute_url_map" "terraform-url-map" {
  name            = "terraform-load-balancer"
  provider        = google-beta
  default_service = google_compute_backend_service.terraform-backend.id
}

resource "google_compute_backend_service" "terraform-backend" {
  name                  = "terraform-backend"
  provider              = google-beta
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 30
  health_checks         = [google_compute_health_check.terraform-health-check.id]
  backend {
    group           = google_compute_instance_group.terraform-instance-group.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_health_check" "terraform-health-check" {
  name = "terraform-health-check"

  tcp_health_check {
    port = "80"
  }
}


