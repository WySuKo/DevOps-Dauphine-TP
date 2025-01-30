terraform {
  backend "gcs" {
    bucket = "tpdevops-449407-tfstate"
    prefix = "DevOps-Dauphine-TP/terraform/state"
  }
}