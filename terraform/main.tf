provider "google" {
  project = var.project_id
  region  = var.region
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.0"
    }
  }
}
resource "google_cloud_run_service" "default" {
  name     = "wordpress-service"
  location = var.region  
  project  = var.project_id  

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/${var.project_id}/website-tools/wordpress-custom:latest" 
        ports {
          container_port = 8080  
        }
      }
    }
  }
 }
resource "google_project_service" "enabled_apis" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "artifactregistry.googleapis.com",
    "sqladmin.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com" 
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

resource "docker_image" "wordpress_custom" {
  name          = "us-central1-docker.pkg.dev/${var.project_id}/website-tools/wordpress-custom:latest"
  build {
    context    = "./Dockerfile"  # Spécifiez le répertoire du Dockerfile
    dockerfile = "./Dockerfile"  # Spécifiez le chemin vers votre Dockerfile
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.default.location
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name
  policy_data = data.google_iam_policy.noauth.policy_data
}