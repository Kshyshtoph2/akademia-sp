terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.52.0"
    }
  }
}

provider "google" {
  credentials = file("keys/credentials.json")
  project     = var.project_id
  region      = var.location["region"]
  zone        = var.location["zone"]
}

provider "google-beta" {
  credentials = file("keys/credentials.json")
  project     = var.project_id
  region      = var.location["region"]
  zone        = var.location["zone"]
}