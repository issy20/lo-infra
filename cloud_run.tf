resource "google_cloud_run_v2_service" "server" {
  name     = "server"
  location = var.gcp_region
  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
    ]
  }
  template {
    scaling {
      max_instance_count = 1
      min_instance_count = 0
    }
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      ports {
        container_port = 8080
      }
      resources {
        limits = {
          cpu    = "1",
          memory = "512Mi"
        }

      }
    }
    service_account = google_service_account.cloud_run_runner.email
  }
}

resource "google_cloud_run_v2_service_iam_binding" "server" {
  location = var.gcp_region
  project  = var.gcp_project_id
  name     = google_cloud_run_v2_service.server.name
  role     = "roles/run.invoker"
  members = [
    "serviceAccount:${google_service_account.cloud_run_runner.email}",
  ]
}

resource "google_cloud_run_v2_service" "client" {
  name     = "client"
  location = var.gcp_region
  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
    ]
  }

  template {
    scaling {
      max_instance_count = 1
      min_instance_count = 0
    }

    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      ports {
        container_port = 3000
      }
      resources {
        limits = {
          cpu    = "1",
          memory = "512Mi"
        }
      }
    }
    service_account = google_service_account.cloud_run_runner.email
  }
}

resource "google_cloud_run_v2_service_iam_member" "client" {
  location = var.gcp_region
  project  = var.gcp_project_id
  name     = google_cloud_run_v2_service.client.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
