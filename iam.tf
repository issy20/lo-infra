locals {
  roles = [
    "roles/run.invoker",
  ]
}

resource "google_service_account" "cloud_run_runner" {
  account_id   = var.gcp_service_account
  display_name = var.gcp_service_account_display_name
  description  = "for running lo app in cloud run"
  project      = var.gcp_project_id
}

resource "google_project_iam_binding" "cloud_run_runner" {
  project  = var.gcp_project_id
  for_each = toset(local.roles)
  role     = each.key
  members = [
    "serviceAccount:${google_service_account.cloud_run_runner.email}"
  ]
}
