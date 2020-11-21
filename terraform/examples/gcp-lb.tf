terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  version = "3.20.0"
  project = "qwiklabs-gcp-03-2042e6f9b5d4"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_firewall" "default" {
    name = "fw-allow-health-checks"
    network = "default"
    target_tags = ["allow-health-checks"]
    source_ranges = ["130.211.0.0/22","35.191.0.0/16"]
    allow {
        protocol = "tcp"
        ports = ["80"]
    }
}

resource "google_compute_router" "us_router" {
  name    = "nat-router-us-central1"
  region  = "us-central1"
  network = "default"

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat_usa" {
  name                               = "nat-usa"
  router                             = google_compute_router.us_router.name
  region                             = google_compute_router.us_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_router" "eu_router" {
  name    = "nat-router-europe-west1"
  region  = "europe-west1"
  network = "default"

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat_eu" {
  name                               = "nat-europe"
  router                             = google_compute_router.eu_router.name
  region                             = google_compute_router.eu_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_instance_template" "default" {
  name        = "us-central1-template"
  description = "This template is used to create app server instances."
  machine_type= "e2-medium"
  region = "us-central1"
  disk {
      source_image = "debian-10-buster-v20201112"
  }
  metadata = {
      startup-script-url = "gs://cloud-training/gcpnet/httplb/startup.sh"
  }
  network_interface {
      network = "default"  
  }
  tags = ["allow-health-checks"]
}

resource "google_compute_instance_template" "europe-west1-template" {
  name        = "europe-west1-template"
  description = "This template is used to create app server instances."
  machine_type= "e2-medium"
  region = "europe-west1"
  disk {
      source_image = "debian-10-buster-v20201112"
  }
  metadata = {
      startup-script-url = "gs://cloud-training/gcpnet/httplb/startup.sh"
  }
  network_interface {
      network = "default"  
  }
  tags = ["allow-health-checks"]
}
