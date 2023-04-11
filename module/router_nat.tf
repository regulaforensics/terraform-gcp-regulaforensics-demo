resource "google_compute_router" "router" {
  name    = var.name
  region  = var.region
  network = module.vpc.network_id
  depends_on = [
    module.vpc
  ]
}

resource "google_compute_router_nat" "nat" {
  name   = var.name
  router = google_compute_router.router.name
  region = var.region

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option             = "MANUAL_ONLY"

  subnetwork {
    name                    = "private-subnet"
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  nat_ips = [google_compute_address.nat.self_link]
  depends_on = [
    module.vpc
  ]
}

resource "google_compute_address" "nat" {
  region       = var.region
  name         = var.name
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
  depends_on = [
    module.vpc
  ]
}
