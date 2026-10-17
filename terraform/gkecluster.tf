resource "google_container_cluster" "retail_cluster" {
  name     = var.cluster_name
  location = var.region

  network    = google_compute_network.retail_vpc.id
  subnetwork = google_compute_subnetwork.retail_subnet.id

  remove_default_node_pool = true
  initial_node_count       = 1

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = "retail-pods"
    services_secondary_range_name = "retail-services"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  release_channel {
    channel = "REGULAR"
  }

  logging_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "WORKLOADS"
    ]
  }

  monitoring_config {
    enable_components = [
      "SYSTEM_COMPONENTS"
    ]
  }

  deletion_protection = true

  depends_on = [
    google_project_service.required
  ]
}

resource "google_container_node_pool" "retail_nodes" {
  name     = "retail-node-pool"
  location = var.region
  cluster  = google_container_cluster.retail_cluster.name

  initial_node_count = var.node_count

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  node_config {
    machine_type    = var.machine_type
    service_account = google_service_account.gke_nodes.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      application = "retail-orders"
      environment = "dev"
    }

    tags = [
      "retail-gke-node"
    ]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  depends_on = [
    google_project_iam_member.gke_node_logging,
    google_project_iam_member.gke_node_monitoring,
    google_project_iam_member.gke_node_resource_metadata,
    google_project_iam_member.gke_node_artifact_reader
  ]
}