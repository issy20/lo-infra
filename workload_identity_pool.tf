locals {
  ci_roles = [
    "roles/artifactregistry.reader",
    "roles/artifactregistry.writer",
    "roles/run.admin",
    "roles/iam.serviceAccountUser",
  ]
}

resource "google_service_account" "github_actions_runner" {
  account_id   = var.gcp_service_account_ci
  display_name = var.gcp_service_account_ci_display_name
}

resource "google_project_iam_binding" "ci_roles_binding" {
  for_each = toset(local.ci_roles)
  role     = each.value
  project  = var.gcp_project_id
  members = [
    "serviceAccount:${google_service_account.github_actions_runner.email}",
  ]
}

resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub"
  project                   = var.gcp_project_id
  provider                  = google-beta
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
  project = var.gcp_project_id
}

resource "google_service_account_iam_binding" "pool_impersonation" {
  provider           = google-beta
  service_account_id = google_service_account.github_actions_runner.id
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.server_repo_name}",
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.client_repo_name}",
  ]
}
