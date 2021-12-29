provider "google" {
  # credentials = file("CREDENTIALS_FILE.json")
  project = "bamboo-reason-336609"
  region  = "asia-northeast1"
}

# // A single Compute Engine instance
resource "google_compute_instance" "default" {
  name                      = "flask-vm-1"
  machine_type              = "f1-micro"
  zone                      = "asia-northeast1-a"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  // Make sure flask is installed on all new instances for later steps
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync; pip install flask"

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.public.name

    access_config {
      // Include this section to give the VM an external ip address
    }
  }
}


resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "private" {
  name          = "private-subnet-network"
  ip_cidr_range = "192.168.0.0/24"
  region        = "asia-northeast1"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "public" {
  name          = "public-subnet-network"
  ip_cidr_range = "192.168.1.0/24"
  region        = "asia-northeast1"
  network       = google_compute_network.vpc_network.id
}
