resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "terraform-subnet"
  ip_cidr_range = "10.0.0.0/22"
  region        = var.location["region"]
  network       = google_compute_network.vpc_network.id
}



resource "google_compute_firewall" "ingress" {
  name    = "firewall-ingress"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "22"]
  }
  direction = "INGRESS"
}


resource "google_compute_address" "static" {
  name       = "vm-public-address"
  project    = var.project_id
  region     = var.location["region"]
  depends_on = [google_compute_firewall.ingress]
}


# UNCOMMENT TO DISABLE OUTGOING INTERNET ACCESS


# resource "google_compute_firewall" "egress" {
#   name    = "firewall-egress"
#   network = google_compute_network.vpc_network.name
#   deny {
#     protocol = "all"
#   }
#   direction = "EGRESS"
#   depends_on = [google_compute_instance.vm_instance]
# }



resource "google_compute_router" "terraform_nat_router" {
  name    = "terraform-nat-router"
  region  = var.location["region"]
  network = google_compute_network.vpc_network.id
}

data "google_compute_zones" "available" {
  region = var.location["region"]
}



resource "google_compute_instance_template" "terraform_instance_template" {
  name                 = "terraform-appserver-template"
  machine_type         = "e2-small"
  can_ip_forward       = false
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
  disk {
    source_image      = var.image_id
    auto_delete = false
    boot        = false
  }
  network_interface {
    network = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.vpc_subnet.id
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      disk[0].boot
    ]
  }
}


resource "google_compute_region_instance_group_manager" "terraform_ig_manager" {
  name                      = "terraform-manager"
  base_instance_name        = "terraform-instance"
  region                    = var.location["region"]
  distribution_policy_zones = data.google_compute_zones.available.names
  target_size               = var.instance_count["min"]
  version {
    instance_template = google_compute_instance_template.terraform_instance_template.self_link
  }
  named_port {
    name   = "http"
    port = 80
  }
  auto_healing_policies {
    health_check      = google_compute_health_check.terraform_health_check.id
    initial_delay_sec = 180
  }
}

resource "google_compute_health_check" "terraform_health_check" {
  name = "terraform-health-check"
  tcp_health_check {
    port = "80"
  }
}

resource "google_compute_region_autoscaler" "terraform_autoscaler" {
  provider = google-beta
  name     = "terraform-autoscaler"
  target   = google_compute_region_instance_group_manager.terraform_ig_manager.self_link
  autoscaling_policy {
    min_replicas    = var.instance_count["min"]
    max_replicas    = var.instance_count["max"]
    cooldown_period = 60
    cpu_utilization {
      target = 0.6
    }
  }
}