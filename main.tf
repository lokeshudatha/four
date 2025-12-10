provider "google" {
  project = "winter-monolith-477705-m8"
  region  = "us-central1"
}

# -----------------------------
# VPC Network
# -----------------------------
resource "google_compute_network" "lokinetwork" {
  name                    = "lokesh-network"
  auto_create_subnetworks = false
}

# -----------------------------
# Subnetwork
# -----------------------------
resource "google_compute_subnetwork" "lokisubnetwork" {
  name          = "lokesh-subnetwork"
  network       = google_compute_network.lokinetwork.id
  region        = "us-central1"
  ip_cidr_range = "10.0.0.0/22"
}

# -----------------------------
# VM Instance
# -----------------------------
resource "google_compute_instance" "loki" {
  name         = "lokesh-udatha"
  zone         = "us-central1-a"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.lokisubnetwork.id

    access_config {}   # Enables public IP
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  depends_on = [
    google_compute_subnetwork.lokisubnetwork
  ]
}

# -----------------------------
# Firewall Rule
# -----------------------------
resource "google_compute_firewall" "lokifirewall" {
  name    = "lokesh-firewall"
  network = google_compute_network.lokinetwork.id

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# -----------------------------
# Outputs for Harness Build Stage
# -----------------------------

# Public IP of VM
output "vm_public_ip" {
  value = google_compute_instance.loki.network_interface[0].access_config[0].nat_ip
}

# Private IP (if needed)
output "vm_private_ip" {
  value = google_compute_instance.loki.network_interface[0].network_ip
}

# SSH User
output "ssh_username" {
  value = "ubuntu"
}

# SSH Private Key (needed for Harness Build Stage)
output "ssh_private_key" {
  value     = file("~/.ssh/id_rsa")
  sensitive = true
}
