provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "enabled_apis" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "artifactregistry.googleapis.com",
    "sqladmin.googleapis.com",
    "cloudbuild.googleapis.com"
  ])
  service = each.key
}

resource "google_artifact_registry_repository" "website_tools" {
  repository_id = "website-tools"
  format        = "DOCKER"
  location      = var.region
  description   = "Registry for WordPress tools"
}

resource "google_sql_database" "wordpress_db" {
  name     = "wordpress"
  instance = "main-instance"
}

resource "google_sql_user" "wordpress_user" {
  name     = "wordpress"
  instance = "main-instance"
  password = "ilovedevops"
}
