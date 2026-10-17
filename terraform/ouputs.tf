output "vpc_name" {
  value = google_compute_network.retail_vpc.name
}

output "subnet_name" {
  value = google_compute_subnetwork.retail_subnet.name
}

output "artifact_registry_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_repository}"
}

output "gke_cluster_name" {
  value = google_container_cluster.retail_cluster.name
}

output "gke_cluster_location" {
  value = google_container_cluster.retail_cluster.location
}

output "gke_node_service_account" {
  value = google_service_account.gke_nodes.email
}