data "google_project" "project" {
  project_id = var.project_id
}

module "gke_regula" {
  source                  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version                 = "25.0.0"
  name                    = var.name
  project_id              = var.project_id
  regional                = var.regional
  zones                   = var.zones
  network                 = module.vpc.network_name
  subnetwork              = "private-subnet"
  ip_range_pods           = var.secondary_ip_ranges[0].range_name
  ip_range_services       = var.secondary_ip_ranges[1].range_name
  enable_private_endpoint = var.enable_private_endpoint
  enable_private_nodes    = var.enable_private_nodes
  release_channel         = "REGULAR"

  master_authorized_networks = var.master_authorized_networks

  node_pools = [
    {
      disk_size_gb = var.disk_size_gb
      disk_type    = var.disk_type
      name         = var.name
      autoscaling  = true
      auto_upgrade = true
      node_count   = var.node_count
      machine_type = var.machine_type
      spot         = var.spot
    },
  ]
  depends_on = [
    module.vpc
  ]
}

