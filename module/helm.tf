data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke_regula.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_regula.ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke_regula.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke_regula.ca_certificate)
  }
}



resource "helm_release" "docreader" {
  count      = var.enable_docreader == true ? 1 : 0
  name       = "docreader"
  repository = "https://regulaforensics.github.io/helm-charts"
  chart      = "docreader"

  values = [
    var.docreader_values
  ]

}

resource "kubernetes_secret" "docreader_license" {
  count = var.enable_docreader == true ? 1 : 0
  metadata {
    name = "docreader-license"
  }
  type = "Opaque"
  binary_data = {
    "regula.license" = var.docreader_license
  }
}
