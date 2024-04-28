terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.0.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "5.0.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}