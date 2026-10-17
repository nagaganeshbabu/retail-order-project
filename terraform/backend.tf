terraform {
  backend "gcs" {
    bucket = "retail-orders-terraform-state-62792d44"
    prefix = "terraform/state"
  }
}