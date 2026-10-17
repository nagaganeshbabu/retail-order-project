resource "google_compute_network" "retail_vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false

  depends_on = [
    google_project_service.required
  ]
}

resource "google_compute_subnetwork" "retail_subnet" {
  name          = var.subnet_name
  region        = var.region
  network       = google_compute_network.retail_vpc.id
  ip_cidr_range = "10.10.0.0/20"

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "retail-pods"
    ip_cidr_range = "10.20.0.0/16"
  }

  secondary_ip_range {
    range_name    = "retail-services"
    ip_cidr_range = "10.30.0.0/20"
  }
}

resource "google_compute_router" "retail_router" {
  name    = "retail-router"
  region  = var.region
  network = google_compute_network.retail_vpc.id
}

resource "google_compute_router_nat" "retail_nat" {
  name                               = "retail-nat"
  router                             = google_compute_router.retail_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}