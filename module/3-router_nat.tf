resource "google_compute_router" "router" {
  name    = var.name
  project = var.project_id
  region  = var.region
  network = module.vpc.network_id

  depends_on = [
    module.vpc,
    module.project
  ]
}

module "cloud-nat" {
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "~> 1.2"
  project_id                         = var.project_id
  region                             = var.region
  router                             = google_compute_router.router.name
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetworks = [{
    name                     = "private-subnet"
    source_ip_ranges_to_nat  = ["ALL_IP_RANGES"]
    secondary_ip_range_names = []
  }]
  nat_ips = [google_compute_address.nat.self_link]
  depends_on = [
    module.vpc,
    module.project
  ]
}

resource "google_compute_address" "nat" {
  region       = var.region
  project      = var.project_id
  name         = var.name
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  depends_on = [
    module.vpc,
    module.project
  ]
}
