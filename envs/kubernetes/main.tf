provider "kubernetes" {}

provider "helm" {}

resource "kubernetes_namespace" "demo" {
  metadata {
    name = "provlift-demo"
  }
}
