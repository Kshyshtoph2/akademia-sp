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

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "e2-small"

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-bionic-v20211021"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.vpc_subnet.id
  }

  metadata_startup_script = file("./scripts/setup.sh")

  depends_on = [
    google_compute_firewall.ingress, google_compute_address.static
  ]
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


resource "google_compute_instance_group" "terraform-instance-group" {
  name      = "terraform-instance-group"
  instances = [google_compute_instance.vm_instance.id]
  named_port {
    name = "http"
    port = "80"
  }
}



resource "google_compute_router" "terraform-nat-router" {
  name    = "terraform-nat-router"
  region  = var.location["region"]
  network = google_compute_network.vpc_network.id
}