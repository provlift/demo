provider "google" {
  project = "provlift-demo"
  region  = "us-central1"
}

resource "google_storage_bucket" "demo" {
  name     = "provlift-demo-bucket"
  location = "US"
}
