provider "github" {}

resource "github_repository" "demo" {
  name       = "provlift-demo"
  visibility = "private"
}
