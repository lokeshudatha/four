provider "google" {
  project     = "winter-monolith-477705-m8"
  region      = "us-central1"
}

resource "google_compute_network" "lokinetwork" {
  name                    = "lokesh-network"
  auto_create_subnetworks = false 
}

resource "google_compute_subnetwork" "lokisubnetwork" {
  name          = "lokesh-subnetwork"
  network       = google_compute_network.lokinetwork.id
  region        = "us-central1"
  ip_cidr_range = "10.0.0.0/22"
}

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
    subnetwork   = google_compute_subnetwork.lokisubnetwork.id
    access_config {}
  }

  depends_on = [
    google_compute_subnetwork.lokisubnetwork
  ]
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y docker.io git
    systemctl start docker
    systemctl enable docker

    # Clone your repository
    git clone https://github.com/lokeshudatha/four /opt/four

    # Build Docker Image
    cd /opt/four
    docker build -t  four-image:latest .
  EOF
}
resource "google_compute_firewall" "lokifirewall" {
  name    = "lokesh-firewall"
  network = google_compute_network.lokinetwork.id

  direction = "INGRESS"

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}


