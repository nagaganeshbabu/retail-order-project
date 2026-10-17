variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-south1"
}

variable "network_name" {
  description = "VPC network name"
  type        = string
  default     = "retail-vpc"
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
  default     = "retail-subnet"
}

variable "artifact_repository" {
  description = "Artifact Registry repository"
  type        = string
  default     = "retail-orders"
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "retail-orders-gke"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "GKE worker node machine type"
  type        = string
  default     = "e2-standard-2"
}